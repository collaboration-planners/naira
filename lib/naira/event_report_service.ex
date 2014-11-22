defmodule Naira.EventReportService do
@moduledoc """
Event report service.
"""
	use DB

	# API 

	def add_event_report([user_id: user_id, headline: headline, description: description]) do
		event_report = event_report(user_id: user_id, headline: headline, description: description)
		Naira.EventManager.event_report_added event_report
		EventReport.add event_report
  end

  def event_report([user_id: user_id, headline: headline, description: description]) do
		%EventReport{user_id: user_id, headline: headline, description: description, date: Timex.Date.epoch(:secs), tags: [], refs: [] }
  end

end
