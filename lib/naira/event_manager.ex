defmodule Naira.EventManager do
	@moduledoc """
Naira's application events manager.
"""

	use DB
	require Logger
	@name __MODULE__

	# API

	@spec start_link() :: {:ok, pid}
	@doc "Called by supervisor to start the event manager"
	def start_link() do
		Logger.debug "Starting Event Manager"
		{:ok, pid} = GenEvent.start_link(name: @name) #Start the event manager and name it
		register_handlers
		{:ok, pid}
	end

	@spec notify_user_added(%User{}) :: :ok
	@doc "Notify event handlers of new user"
	def notify_user_added(user) do
		Logger.debug "Notifying: user #{user.name} was added"
		GenEvent.notify(@name, {:user_added, user})
	end

	@spec notify_event_report_added(%EventReport{}) :: :ok
  @doc "Notify event handlers of new event report"
  def notify_event_report_added(event_report) do
		Logger.debug "Notifying: event report \"#{event_report.headline}\" was added"
    GenEvent.notify(@name, {:event_report_added, event_report})
  end

	# Private

	# Register all handlers
	defp register_handlers() do
		Logger.debug "Registering event handlers"
		GenEvent.add_handler(@name, Naira.InternalEventHandler, [])
  end

end
