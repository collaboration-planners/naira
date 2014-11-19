defmodule Naira.EventReportServer do
	@moduledoc """
Stores and retrieves the event reports of a given user.
"""
	use GenServer
	# API

	@doc "Store an event report"
	def add_event_report(event_report) do
		GenServer.cast(__MODULE__, {:add, event_report})
	end

	# Callbacks
	def init(_) do
		db = init_db()
		{:ok, %{db: db}}
	end

	def handle_cast({:add, event_report}, %{db: db}=state) do 
		# TODO - Store in DB
		{:noreply, state}
	end

	# Private
	defp init_db() do

	end

end
