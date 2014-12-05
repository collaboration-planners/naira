defmodule Naira.TopSupervisor do
	@moduledoc """
Naira's top supervisor. It supervises the Event Manager, the Atom Pool and the Stream Supervisor.
"""
	@name __MODULE__
	use Supervisor

  def start_link() do
		IO.puts "Starting top supervisor"
		{:ok, _pid} = Supervisor.start_link(@name, [], [name: @name])
	end 

	def init(_) do
		children = [
								 worker(Naira.EventManager, []),
								 worker(Naira.AtomPool, [100]), #pre-populate atom pool with 100 reusable atoms
								 supervisor(Naira.StreamsSupervisor, [])
						   ]
		opts = [strategy: :one_for_one]
		supervise(children, opts)
	end

end
