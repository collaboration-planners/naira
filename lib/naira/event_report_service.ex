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

	def get_all_event_reports() do
		EventReport.get_all
  end

  def get_user_event_reports(user_id) do
		EventReport.get_all user_id
	end

	def get_event_report(id) do
		EventReport.get id
  end

	def destroy_event_report(id) do
		EventReport.destroy id
		# TODO Raise event?
  end

end
