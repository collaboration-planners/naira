defmodule Naira.EventsController do

	use Phoenix.Controller
	require Naira.WebUtils
  import Naira.WebUtils, only: [key_protected: 3, default: 2]
	alias Poison, as: JSON
	plug :action

	# Authenticated API

  def index(conn, %{"user" => s_user_id, "key" => api_key}) do
		key_protected(conn, api_key) do
			user_id = String.to_integer s_user_id
			json conn, JSON.encode!(Naira.EventReportService.get_user_event_reports user_id)
    end
	end
  def index(conn, %{"key" => api_key}) do
		key_protected(conn, api_key) do
			json conn, JSON.encode!(Naira.EventReportService.get_all_event_reports)
		end
	end

  def show(conn, %{"id" => s_id, "key" => api_key}) do
		key_protected(conn, api_key) do
			id = String.to_integer s_id
			json conn, JSON.encode!(Naira.EventReportService.get_event_report id)
		end
	end
	
  def create(conn, params) do
		api_key = params["key"]
		key_protected(conn, api_key) do
			user = Naira.UserService.get_user_with_api_key(api_key)
			event_map = %{user_id: user.id, headline: default(params["headline"],"?"), description: default(params["description"],""), tags: default(params["tags"],[]), location: default(params["location"],""), refs: default(params["refs"],[])}
			event_report = Naira.EventReportService.add_event_report(event_map)
			json conn, JSON.encode! event_report
		end
  end

	def destroy(conn, %{"id" => s_id, "key" => api_key}) do
		key_protected(conn, api_key) do
			id = String.to_integer s_id
			result = Naira.EventReportService.destroy_event_report id
			json conn, JSON.encode! result
		end
  end

end
