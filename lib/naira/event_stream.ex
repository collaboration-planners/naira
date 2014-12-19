defmodule EventStream do
	@moduledoc """
A cyclic event report stream based on an event stream definition.
"""

  use DB
	@derive Access

	@doc " An event stream definition struct"
	defstruct name: nil, event_stream_def: nil, current: nil, user: nil, sub_event_streams: [], sub_cursor: 0

	### API

	@spec start(atom, %EventStreamDef{}, %User{}) :: %EventReport{} | nil
	@doc "Create a new event stream and return first event report from it"
	def start(name, event_stream_def, user) do 
		new(name, event_stream_def, user)
  end

	@spec next(%EventStreamDef{}) :: {%EventReport{},%EventStream{}} | nil
	@doc "Return the next event report in the stream together with the advanced on stream. If at end, return nil and reset the stream to the beginning."
	def next(event_stream = %EventStream{}) do
	  advanced = advance event_stream
    {current(advanced), advanced}
  end

	@spec at_end?(%EventStream{}) :: boolean
  @doc "Whether an event stream is at end"
	def at_end?(event_stream = %EventStream{}) do
		if atomic? event_stream do
			event_stream.current == nil
		else
			Enum.all(event_stream.sub_event_streams, &at_end?(&1))
    end
  end

  @spec reset(%EventStream{}) :: %EventStream{}
  @doc "Reset an event stream"
	def reset(event_stream = %EventStream{}) do
		reset_sub_event_streams = Enum.map(event_stream.sub_event_streams, fn(ses) -> reset(ses) end)
		%{event_stream|sub_cursor: 0, current: nil, sub_event_streams: reset_sub_event_streams}
  end

	def label(event_stream = %EventStream{}) do
		"#{event_stream.event_stream_def.description}"
  end

	### Private

	def current(event_stream = %EventStream{}) do
		if atomic? event_stream do
			event_stream.current
    else
			current( current_sub_stream(event_stream) )
    end
  end

	defp current_sub_stream(event_stream = %EventStream{}) do
		sub_name = get_sub_name(event_stream, event_stream.sub_cursor)
		Naira.EventStreamService.get_event_stream(sub_name)
  end

  defp new(name, event_stream_def, user) do
		# TODO: check for circularity in sub_event_streams
		%EventStream{name: name, event_stream_def: event_stream_def, user: user, sub_event_streams: event_stream_def.sub_stream_defs} # a sub_event_stream as integer => not started yet from the event_stream_def
  end

  defp advance(event_stream = %EventStream{}) do
		if atomic? event_stream do
			advance_atomic event_stream
    else
			updated = advance_subs event_stream
			apply_filters(current(updated), updated)
    end
  end

  defp advance_atomic(event_stream = %EventStream{}) do
		IO.puts "Advance atomic -- #{label event_stream}"
		updated = tick event_stream
		apply_filters(updated.current, updated)
	end

  defp tick(event_stream = %EventStream{}) do
		if event_stream.current === nil do
			move_to_first event_stream
    else
			move_to_next event_stream
    end
  end

	def move_to_first(event_stream = %EventStream{}) do
		IO.puts "Move to first --  #{label event_stream}"
		event_report = EventReport.get_first
		%{event_stream | current: event_report}
	end

	def move_to_next(event_stream = %EventStream{}) do
		IO.puts "Move to next -- #{label event_stream}"
		event_report = EventReport.get_next event_stream.current
		%{event_stream | current: event_report}
	end

	defp atomic?(event_stream = %EventStream{}) do
		Enum.empty? event_stream.sub_event_streams
	end

	defp advance_subs(event_stream = %EventStream{}) do
		IO.puts "Advance subs -- #{label event_stream}"
		%EventStream{} = advance_subs(event_stream, event_stream.sub_cursor, event_stream.sub_cursor, :init)
	end
	defp advance_subs(event_stream = %EventStream{}, start_cursor, start_cursor, state) when state !== :init do
		IO.puts "Tried all subs from #{start_cursor} --  #{label event_stream}"
		event_stream
	end
	defp advance_subs(event_stream = %EventStream{}, start_cursor, cursor, _state) do
		IO.puts "Attempting to advance sub #{cursor} --  #{label event_stream}"
		sub_event_streams = event_stream.sub_event_streams
		if cursor >= Enum.count(sub_event_streams) do
			updated = %{event_stream | sub_cursor: 0}
			advance_subs(updated, start_cursor, 0, :moved)
		else
			sub_event_stream_name = get_sub_name(event_stream, cursor)
			event_report = Naira.EventStreamService.next(sub_event_stream_name)
			updated_subs = replace(sub_event_streams, cursor, sub_event_stream_name)
			updated = %{event_stream | sub_event_streams: updated_subs}
			if event_report === nil do
				IO.puts "At end of sub #{cursor} -- #{label event_stream}"
				new_updated = %{updated | sub_cursor: cursor + 1}
				advance_subs(new_updated, start_cursor, cursor + 1, :moved)
				# TODO - Remember which subs are at end and ignore them until all are at end
			else
				IO.puts "Successsfully advanced sub #{cursor} of #{label event_stream}"
				updated
			end
		end
	end

	# Lazy starting of sub streams (recursive starts => deadlocks)
	defp get_sub_name(event_stream = %EventStream{}, cursor) do
		es = Enum.at(event_stream.sub_event_streams, cursor)
		case es do
			a when is_atom(a) -> es
			i when is_integer(i) -> 
					IO.puts "Lazily starting event stream from def #{i}"
					Naira.EventStreamService.start_event_stream(event_stream_def_id: i, user: event_stream.user)
		end
  end

 	defp replace([_first|rest], 0, item) do
		[item|rest]
	end
	defp replace([first|rest], index, item) when index > 0 do
		[first|replace(rest, index-1, item)]
	end

	# Advance the stream until an event report passes the filters or the end is reached.
	defp apply_filters(nil, event_stream = %EventStream{}) do
		event_stream
	end
	defp apply_filters(event_report, event_stream = %EventStream{}) do
		IO.puts "Applying filters to #{inspect event_report}"
		filters = event_stream.event_stream_def.filters
		passes = Enum.all?(filters, 
											 fn(filter) -> apply(Naira.Filter.mod_from_type(filter.type), :passes?, [event_report,filter.options, event_stream.user]) end)
		if passes do
			IO.puts "Passed"
			event_stream
		else
			IO.puts "NOT passed"
			advance event_stream
		end
	end

end
