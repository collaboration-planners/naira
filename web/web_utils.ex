defmodule Naira.WebUtils do
	@moduledoc """
Utility functions and macros for Web access.
"""

	use Phoenix.Controller
	alias Poison, as: JSON

	plug :action

	# Executes the protected block if the api key is verified, else throws a 500 error.
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

	@spec default(any,any) :: any
  @doc "Returns the value if not nil, esle returns the default value"
	def default(nil, default_value) do
    default_value
  end
  def default(value, _) do
	  value
  end


end
