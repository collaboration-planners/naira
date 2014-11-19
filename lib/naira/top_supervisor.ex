defmodule Naira.TopSupervisor do
	@moduledoc """
Naira's top supervisor.
"""
	use Supervisor

  def start_link(_) do
		:mnesia.create_schema([node()])
		:mnesia.start()
	end 

	def init(_) do
		children = [worker(Naira.EventReportServer, [])]
		opts = [strategy: :one_for_one]
		supervise(children, opts)
	end

end
