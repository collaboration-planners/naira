defmodule Naira.WebUtils do
	@moduledoc """
Utility functions and macros for Web access.
"""

	use Phoenix.Controller
	alias Poison, as: JSON

	plug :action

	defmacro key_protected(conn, api_key, protected) do
    quote do
			if Naira.UserService.verify_key(unquote(api_key)) do
				unquote(protected)
				unquote(conn)
			else
			  json unquote(conn), 500, JSON.encode!(%{error: :wrong_key})
			end
    end
	end

end
