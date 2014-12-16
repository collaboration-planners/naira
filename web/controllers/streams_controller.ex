defmodule Naira.StreamsController do

	use Phoenix.Controller
	require Naira.WebUtils
  import Naira.WebUtils, only: [key_protected: 3, default: 2]
	alias Poison, as: JSON
	plug :action

	# Authenticated API

  def show(conn, %{"id" => s_name,"key" => api_key}) do
		key_protected(conn, api_key) do
			name = String.to_atom s_name
			next = Naira.EventStreamService.next name
			json conn, JSON.encode! next
		end
	end

	# Event streams from ad-hoc event stream definitions
  def create(conn, %{"type" => type, "key" => api_key, "user" => user_id}) when type == "user" do
		key_protected(conn, api_key) do
			source = Naira.UserService.get_user_with_id user_id
			user = Naira.UserService.get_user_with_api_key(api_key)
			if source !== nil do
				stream_id = Naira.EventStreamService.user_event_stream([source: source, user: user])
				json conn, JSON.encode! %{stream: stream_id}
			else
				json conn, JSON.encode! nil
			end
		end
  end
  def create(conn, %{"type" => type, "key" => api_key}) when type == "universal"  do
		key_protected(conn, api_key) do
			user = Naira.UserService.get_user_with_api_key(api_key)
			if user != nil do
				name =  Naira.EventStreamService.universal_event_stream(user)
				json conn, JSON.encode! %{stream: name}
			end
		end
  end
	def create(conn, %{"type" => type, "key" => api_key, "properties" => properties}) when type == "properties" do
		key_protected(conn, api_key) do
			user = Naira.UserService.get_user_with_api_key(api_key)
			filter_options = FilterOptions.from_map(properties)
			name =  Naira.EventStreamService.properties_event_stream([filter_options: filter_options, user: user])
			json conn, JSON.encode! %{stream: name}
    end
  end
  # Event stream from pre-defined event stream def
  def create(conn, %{"key" => api_key, "def" => s_def_id}) do
		key_protected(conn, api_key) do
			stream_def_id = String.to_integer(s_def_id)
			user = Naira.UserService.get_user_with_api_key(api_key)
			event_stream_def = Naira.EventStreamDefService.get_visible(stream_def_id, user)
			if event_stream_def !== nil do
				name = Naira.EventStreamService.event_stream(event_stream_def, user)
        json conn, JSON.encode! %{stream: name}
      else
				json conn, JSON.encode! %{error: :not_found}
			end
    end
  end

	def destroy(conn, %{"id" => s_name, "key" => api_key}) do
		key_protected(conn, api_key) do
			name = String.to_atom s_name
			result = Naira.EventStreamService.stop name
			json conn, JSON.encode! result
		end
  end

end
