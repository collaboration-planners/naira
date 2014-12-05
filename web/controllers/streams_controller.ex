defmodule Naira.StreamsController do

	use Phoenix.Controller
	require Naira.WebUtils
  import Naira.WebUtils, only: [key_protected: 3]
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

  def create(conn, %{"user" => s_user_id,"key" => api_key}) do
		key_protected(conn, api_key) do
			user_id = String.to_integer s_user_id
			user = Naira.UserService.get_user_with_id user_id
			if user !== nil do
				name = Naira.EventStreamService.user_event_stream(user)
				json conn, JSON.encode! %{stream: name}
			else
				json conn, JSON.encode! nil
			end
		end
  end
  def create(conn, %{"universal" => _, "key" => api_key}) do
		key_protected(conn, api_key) do
			name =  Naira.EventStreamService.universal_event_stream
			json conn, JSON.encode! %{stream: name}
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
