defmodule Naira.EventReportService do
@moduledoc """
Event report service.
"""
	use DB

	# API 

	@spec add_event_report([user_id: non_neg_integer, headline: String.t, description: String.t]) :: %EventReport{}
	@doc "Add new event report"
	def add_event_report([user_id: user_id, headline: headline, description: description]) do
		event_report = event_report(user_id: user_id, headline: headline, description: description)
		Naira.EventManager.notify_event_report_added event_report
		EventReport.add event_report
  end

	@spec event_report([user_id: non_neg_integer, headline: String.t, description: String.t]) :: %EventReport{}
  @doc "Create a new event report"
  def event_report([user_id: user_id, headline: headline, description: description]) do
		%EventReport{user_id: user_id, headline: headline, description: description, date: Timex.Date.epoch(:secs), tags: [], refs: [] }
  end

	@spec get_all_event_reports() :: [%EventReport{}]
  @doc "Get all known event reports"
	def get_all_event_reports() do
		EventReport.get_all
  end

	@spec get_user_event_reports(non_neg_integer) :: [%EventReport{}]	
	@doc "Get all event reports authored by a user with given id"
  def get_user_event_reports(user_id) do
		EventReport.get_all user_id
	end

	@spec get_event_report(non_neg_integer) :: %EventReport{} | nil
	@doc "Get an event report given its unique id."
	def get_event_report(id) do
		EventReport.get id
  end

	@spec destroy_event_report(non_neg_integer) :: :ok | {:error, any}
	def destroy_event_report(id) do
		EventReport.destroy id
		# TODO Raise event?
  end

end
