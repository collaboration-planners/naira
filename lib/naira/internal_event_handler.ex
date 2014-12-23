defmodule Naira.InternalEventHandler do
	@moduledoc """
Handles internal Naira events.
"""
	use GenEvent
	require Logger

	# Callbacks

	@spec init(any) :: {:ok, any}
	@doc "Event handler call initialization callback method."
	def init(_) do
		Logger.debug "Internal event handler started"
		{:ok, []}
  end

  @spec handle_event({atom, any}, any) :: {:ok, any}
	@doc "Event handling."
  def handle_event({:user_added, user}, state) do
		# Create an event report and store it
		date = Timex.DateFormat.format!(Timex.Date.now, "{RFC1123}")
		Naira.EventReportService.add_event_report(%{user_id: Naira.UserService.naira_id, headline: "New user #{user.name}", description: "User #{user.name} at #{user.email} was added on #{date}"})
		Logger.debug "Handled event: Added event report about new user #{user.name}"
    # Create event stream definitions
    if Naira.UserService.user_naira?(user) do
      		Naira.EventStreamDefService.add_universal_event_stream_def
					Logger.debug "Handled event: Added universal event stream def for user #{user.name}"
    end
		Naira.EventStreamDefService.add_user_event_stream_def(user)
		Logger.debug "Handled event: Added event stream def for new user #{user.name}"
    {:ok, state}
  end
  def handle_event({:event_report_added, _event_report}, state) do
		#TODO something
		{:ok, state}
  end
	
end
