defmodule Naira.EventStream do
	@moduledoc """
A cyclic event report stream based on an event report def.
"""

  use DB
	@derive Access

	defstruct event_stream_def: nil, current: nil

	def start(event_stream_def) do  #returns an EventStream
		event_stream = new event_stream_def
    advance event_stream
  end

	def next(self) do
		current = self.current
		new_state = advance self
    {current, new_state}
  end

  defp new(event_stream_def) do
		%Naira.EventStream{event_stream_def: event_stream_def}
  end

	def advance(self = %Naira.EventStream{current: current}) when current == nil do
		event_report = Amnesia.transaction do EventReport.first end
		updated = %Naira.EventStream{self | current: event_report}
		filter(event_report, updated)
	end
  def advance(self) do
		event_report = Amnesia.transaction do EventReport.next self.current end
		updated = %Naira.EventStream{self | current: event_report}
		filter(event_report, updated)
	end

	defp filter(nil, self) do
		self
  end
	defp filter(event_report, self) do
		if EventStreamDef.is_universal(self.event_stream_def) do
			apply_filters(event_report, self)
    else
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
