defmodule Naira.TopSupervisor do
	@moduledoc """
Naira's top supervisor.
"""
	@name __MODULE__
	use Supervisor

  def start_link() do
		IO.puts "Starting top supervisor"
		{:ok, _pid} = Supervisor.start_link(@name, [])
	end 

	def init(_) do
		children = [
								 worker(Naira.EventManager, []),
								 supervisor(Naira.StreamsSupervisor, [])
						   ]
		opts = [strategy: :one_for_one]
		supervise(children, opts)
	end

end
