defmodule Naira.EventStream do
	@moduledoc """
A cyclic event report stream based on an event stream definition.
"""

  use DB
	@derive Access

	@doc " An event stream definition struct"
	defstruct event_stream_def: nil, current: nil

### API

	@spec start(%EventStreamDef{}) :: %EventReport{} | nil
	@doc "Create a new event stream and return first event report from it"
	def start(event_stream_def) do 
		event_stream = new event_stream_def
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

  defp new(event_stream_def) do
		%Naira.EventStream{event_stream_def: event_stream_def}
  end

	# Advance when at end.
	defp advance(self = %Naira.EventStream{current: current}) when current == nil do
		event_report = Amnesia.transaction do EventReport.first end
		updated = %Naira.EventStream{self | current: event_report}
		filter(event_report, updated)
	end
	# Advance when not at end.
  defp advance(self) do
		event_report = Amnesia.transaction do EventReport.next self.current end
		updated = %Naira.EventStream{self | current: event_report}
		filter(event_report, updated)
	end

	# Advance the stream until a candidate, non-filtered out event report is reached.
	defp filter(nil, self) do
		self
  end
	defp filter(event_report, self) do
		if EventStreamDef.universal?(self.event_stream_def) do # All event reports are candidates for a universal stream with or without filters
			apply_filters(event_report, self)
    else
			#Only event reports authored by a user are candidate for that user's event stream
			if event_report.user_id == self.event_stream_def.user_id do
				apply_filters(event_report, self)
      else
				advance self
			end
		end
		
  end

  defp apply_filters(_event_report, self) do
		self
		#TODO apply the event stream def filters
  end

end
