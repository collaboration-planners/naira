defmodule Naira.StreamDefsController do
	@moduledoc """
   The controller for event stream definitions.
  """

	use Phoenix.Controller
  use DB
	require Naira.WebUtils
  import Naira.WebUtils, only: [key_protected: 3, default: 2]
	alias Poison, as: JSON
	plug :action

	# Authenticated API

	def index(conn, %{"key" => api_key}) do
		key_protected(conn, api_key) do
			user =  Naira.UserService.get_user_with_api_key(api_key)
			if user !== nil do
				json conn, JSON.encode!(Naira.EventStreamDefService.get_all_visible(user))
      else
				json conn, JSON.encode! nil
      end
		end
	end

	def show(conn, %{"id" => s_id, "key" => api_key}) do
		key_protected(conn, api_key) do
			user =  Naira.UserService.get_user_with_api_key(api_key)
			if user !== nil do
				id = String.to_integer(s_id)
				stream_def = Naira.EventStreamDefService.get_visible(id, user)
				json conn, JSON.encode! stream_def
      else
				json conn, JSON.encode! nil
      end
		end
	end

	def create(conn, %{"key" => api_key, "type" => type, "definition" => definition}) do
		key_protected(conn, api_key) do
			user =  Naira.UserService.get_user_with_api_key(api_key)
			event_stream_def = from_definition(type, definition, user)
			added = Naira.EventStreamDefService.add(event_stream_def)
			json conn, JSON.encode! added
    end
  end

	def destroy(conn, %{"id" => s_id, "key" => api_key}) do
		key_protected(conn, api_key) do
			id = String.to_integer(s_id)
			user =  Naira.UserService.get_user_with_api_key(api_key)
			stream_def = Naira.EventStreamDefService.get_visible(id, user)
			if stream_def === nil do
				json conn, JSON.encode! %{error: :not_found}
			else
				Naira.EventStreamDefService.remove(stream_def)
				json conn, JSON.encode! :ok
      end
	  end
  end

	defp from_definition(type, definition, user) do
		description = default(definition["description"], "NO DESCRIPTION")
		shared = default(definition["shared"], false)
		source_stream_defs = default(definition["source_stream_defs"],[])
		event_stream_def = %EventStreamDef{description: description, user_id: user.id, shared: shared, source_stream_defs: source_stream_defs}
		case type do
			"properties" ->
				filter_options = FilterOptions.from_map(default(definition["properties"], %{}))
				filter_def = %FilterDef{type: PropertyFilter.type, options: filter_options}
				%{event_stream_def|filters: [filter_def]}
			"universal" -> event_stream_def
	    _ -> {:error, :unknown_stream_def_type}
		end
	end

end
