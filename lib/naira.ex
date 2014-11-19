defmodule Naira do
	@moduledoc """
The Naira OTP application
"""
	use Application

	def start(_type, _args) do
		{:ok, _pid} = Naira.TopSupervisor.start_link([])
	end

end
