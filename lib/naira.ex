defmodule Naira do
@moduledoc """
The Naira application. It starts Mnesia, initializing it if needed, and starts the Phoenix supervisor.
"""
  use Application

### Application Callbacks

@spec start(atom, any) :: {:ok, pid}
@doc "Starts the Naira application"
def start(_type, _args) do
    import Supervisor.Spec, warn: false
		Application.start :logger
		:ok = Amnesia.start
		IO.puts "Mnesia started"
    children = [
      # Define workers and child supervisors to be supervised
       supervisor(Naira.MainSupervisor, [])
    ]
    opts = [strategy: :one_for_one, name: Phoenix.Supervisor]
    {:ok, pid} = Supervisor.start_link(children, opts)
    initialize_db
		{:ok, pid}
  end

  @spec stop(any) :: any
  @doc "Stops the Naira application"
	def stop(_) do
		Amnesia.stop
  end

### API

	@doc "Starts Phoenix manually"
	def start_phoenix() do
		Mix.Tasks.Phoenix.Start.run []
	end

### Private

  # Adds the universal stream definition and the Naira user to the database, if not already there.
	defp initialize_db() do
		Naira.EventStreamDefService.add_universal_event_stream_def
		Naira.UserService.add_user_naira
  end

end
