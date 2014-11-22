defmodule Naira.InternalEventHandler do
	@moduledoc """
Handles internal Naira events.
"""
	use GenEvent

	# Callbacks
	def init(_) do
		IO.puts "Internal event handler started"
		{:ok, []}
  end

  def handle_event({:user_added, user}, state) do
		# Create an event report and store it
		date = Timex.DateFormat.format!(Timex.Date.now, "{RFC1123}")
		Naira.EventReportService.add_event_report(user_id: Naira.UserService.naira_id, headline: "New user #{user.name}", description: "User #{user.name} at #{user.email} was added on #{date}")
		IO.puts "Handled event: Added event report about new user #{user.name}"
    # Create user event stream
		Naira.EventStreamDefService.add_user_event_stream_def(user)
		IO.puts "Handled event: Added event stream def for new user #{user.name}"
    {:ok, state}
  end
  def handle_event({:event_report_added, _event_report}, state) do
		#TODO something
		{:ok, state}
  end
	
end
