defmodule Naira.EventStream do
	@moduledoc """
A cyclic event report stream based on an event report def.
"""
	#TODO - Implement the Stream protocol

  use DB
	@derive Access

	defstruct event_stream_def: nil, current: nil

  def new(event_stream_def) do
		%Naira.EventStream{event_stream_def: event_stream_def}
  end

	def next(self = %Naira.EventStream{current: current}) when current == nil do
		event_report = Amnesia.transaction do EventRecord.first end
		%Naira.EventStream{self | current: event_report}
		filter(event_report, self)
	end
  def next(self) do
		event_report = Amnesia.transaction do EventRecord.next self.current end
		%Naira.EventStream{self | current: event_report}
		filter(event_report, self)
  end

	defp filter(nil, _self) do
		nil
  end
	defp filter(event_report, self) do
		if EventStreamDef.is_universal(self.event_stream_def) do
			apply_filters(event_report, self)
    else
			if event_report.user_id == self.event_stream_def.user_id do
				apply_filters(event_report, self)
      else
				next self
			end
		end
		
  end

  defp apply_filters(event_report, self) do
		event_report
		#TODO apply the event stream def filters
  end

end
