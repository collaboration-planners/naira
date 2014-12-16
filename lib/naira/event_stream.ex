defmodule Naira.EventStream do
	@moduledoc """
A cyclic event report stream based on an event stream definition.
"""

  use DB
	@derive Access

	@doc " An event stream definition struct"
	defstruct event_stream_def: nil, current: nil, user: nil, sources: [] # if empty, the source of event reports to filter is the Universal stream, else list of source stream names

### API

	@spec start(%EventStreamDef{}, %User{}) :: %EventReport{} | nil
	@doc "Create a new event stream and return first event report from it"
	def start(event_stream_def, user) do 
		event_stream = new(event_stream_def, user)
		# TODO: initialize source event streams if any
    advance event_stream
  end

	@spec next(%EventStreamDef{}) :: {%EventReport{},%Naira.EventStream{}} | nil
	@doc "Return the next event report in the stream together with the advanced on stream. If at end, return nil and reset the stream to the beginning."
	def next(self) do
		current = self.current
	  advanced_self = advance self
    {current, advanced_self}
  end

### Private

  defp new(event_stream_def, user) do
		%Naira.EventStream{event_stream_def: event_stream_def, user: user}
  end

	# Advance when at end.
	defp advance(self = %Naira.EventStream{current: current}) when current == nil do
		event_report = first_event_report(self)
		updated = %Naira.EventStream{self | current: event_report}
		apply_filters(event_report, updated)
	end
	# Advance when not at end.
  defp advance(self) do
		event_report = next_event_report(self)
		updated = %Naira.EventStream{self | current: event_report}
		apply_filters(event_report, updated)
	end

	defp first_event_report(self) do
		#TODO: if source not Universal, get first from first source
		Amnesia.transaction do EventReport.first end
  end

  defp next_event_report(self) do
		#TODO: if source not Universal, get next from round-robbin over sources, skipping at end sources
    # Return nil when all sources at end
		Amnesia.transaction do EventReport.next self.current end
  end

	# Advance the stream until an event report passes the filters or the end is reached.
	defp apply_filters(nil, self) do
    self
  end
  defp apply_filters(event_report, self) do
		filters = self.event_stream_def.filters
		passes = Enum.all?(filters, 
											 fn(filter) -> apply(Naira.Filter.mod_from_type(filter.type), :passes?, [event_report,filter.options, self.user]) end)
		if passes do
			self
    else
      advance self
    end
  end

end
