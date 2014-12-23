defmodule Naira.StreamsSupervisor do
	@moduledoc """
The event report stream supervisor.
"""

@name __MODULE__
use Supervisor
use DB

# CALLBACKS

@spec start_link() :: {:ok, pid}
@doc "Starts the event stream supervisor. Called by the main supervisor."
def start_link() do
	IO.puts "Starting streams supervisor"
	{:ok, _pid} = Supervisor.start_link(@name, [], [name: @name])
end

@spec init(any) :: {:ok, tuple}
@doc "Initialization callback. The supervisor is configured to dynamically start event streams asagents."
def init(_) do
	children = [worker(Naira.EventStreamService, [], restart: :transient)]
  supervise(children, strategy: :simple_one_for_one)
end

# API

@spec start_event_stream(atom, %EventStreamDef{}, %User{}, %EventStream{}) :: {:ok, pid}
@doc "Dynamically starts an event stream as agent."
def start_event_stream(name, event_stream_def, user, super_event_stream \\ nil) do
	Supervisor.start_child(@name, [name, event_stream_def, user, super_event_stream])
end

end
