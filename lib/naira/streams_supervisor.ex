defmodule Naira.StreamsSupervisor do
	@moduledoc """
Event report stream supervisor.
"""

@name __MODULE__
use Supervisor

def start_link() do
	IO.puts "Starting streams supervisor"
	{:ok, _pid} = Supervisor.start_link(@name, [], [name: @name])
end

def init(_) do
	children = [worker(Naira.EventStreamService, [], restart: :transient)]
  supervise(children, strategy: :simple_one_for_one)
end

def start_event_stream(event_stream_def) do
	Supervisor.start_child(@name, [event_stream_def]) # returns {:ok, pid} -- pid of EventStreamer
end

end
