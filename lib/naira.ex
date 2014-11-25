defmodule Naira do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
def start(_type, _args) do
    import Supervisor.Spec, warn: false
		Application.start :logger
		:ok = Amnesia.start
		IO.puts "Mnesia started"

    children = [
      # Define workers and child supervisors to be supervised
       supervisor(Naira.TopSupervisor, [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Phoenix.Supervisor]
    {:ok, pid} = Supervisor.start_link(children, opts)
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

	def start_phoenix() do
		Mix.Tasks.Phoenix.Start.run []
	end
end
