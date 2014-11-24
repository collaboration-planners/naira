defmodule Naira.EventsController do

	use Phoenix.Controller
	alias Poison, as: JSON
	plug :action

  def index(conn, %{"user" => s_user_id}) do
		user_id = String.to_integer s_user_id
		json conn, JSON.encode!(Naira.EventReportService.get_user_event_reports user_id)
	end
  def index(conn, _) do
		json conn, JSON.encode!(Naira.EventReportService.get_all_event_reports)
	end

  def show(conn, %{"id" => s_id}) do
		id = String.to_integer s_id
		json conn, JSON.encode!(Naira.EventReportService.get_event_report id)
	end
	
  def create(conn, params) do
		event_report = Naira.EventReportService.add_event_report(user_id: params["user_id"],  headline: params["headline"], description: params["description"])
		json conn, JSON.encode! event_report
  end

	def destroy(conn, %{"id" => s_id}) do
		id = String.to_integer s_id
		result = Naira.EventReportService.destroy_event_report id
		json conn, JSON.encode! result
  end

end
