defmodule Naira.StreamsSupervisor do
	@moduledoc """
Event report stream supervisor.
"""

@name __MODULE__
use Supervisor

# CALLBACKS

def start_link() do
	IO.puts "Starting streams supervisor"
	{:ok, _pid} = Supervisor.start_link(@name, [], [name: @name])
end

def init(_) do
	children = [worker(Naira.EventStreamService, [], restart: :transient)]
  supervise(children, strategy: :simple_one_for_one)
end

# API

def start_event_stream(name, event_stream_def) do
	IO.puts "Starting event stream #{name}"
	Supervisor.start_child(@name, [name, event_stream_def])
end

end
