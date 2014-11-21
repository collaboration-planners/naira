defmodule Naira do
	@moduledoc """
The Naira OTP application
"""
	use Application

	def start(_type, _args) do
		IO.puts "Starting Naira application"
		:ok = Amnesia.start
		IO.puts "Mnesia started"
		{:ok, pid} = Naira.TopSupervisor.start_link()
    initialize_db
		{:ok, pid}
	end

	defp initialize_db() do
		Naira.EventStreamDefService.add_universal_event_stream_def
		Naira.UserService.add_user_naira
  end

	def stop(_) do
		Amnesia.stop
  end

end
