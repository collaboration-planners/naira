defmodule Naira.EventManager do
	@moduledoc """
Naira's event manager
"""
	@name __MODULE__

	# API

	# Called by supervisor
	def start_link() do
		IO.puts "Starting Event Manager"
		{:ok, pid} = GenEvent.start_link(name: @name) #Start the event manager and name it
		register_handlers
		{:ok, pid}
	end

	def user_added(user) do
		IO.puts "Notifying: user #{user.name} was added"
		GenEvent.notify(@name, {:user_added, user})
	end

  def event_report_added(event_report) do
		IO.puts "Notifying: event report \"#{event_report.headline}\" was added"
    GenEvent.notify(@name, {:event_report_added, event_report})
  end

	# Private
	defp register_handlers() do
		IO.puts "Registering event handlers"
		GenEvent.add_handler(@name, Naira.InternalEventHandler, [])
  end

end
