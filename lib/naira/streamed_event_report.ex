defmodule StreamedEventReport do
@moduledoc """
Meta data for a streamed event report.
"""

defstruct event_report: nil, streamed_on: nil, event_stream_def_id: nil, user_streaming: nil, at_end: false

    def new(event_report, event_stream) do
			%{event_report: event_report,
        streamed_on: Timex.Date.now(:secs), 
				event_stream_def_id: event_stream.event_stream_def.id,
				user_streaming: event_stream.user.id,
				at_end: event_stream.at_end}
		end

    def empty?(streamed_event_report) do
			streamed_event_report.event_report === nil
    end

end
