defmodule Naira.EventStreamService do
	@moduledoc """
Event report stream as supervised agent.
"""

	# Supervisor callbacks

	def start_link(event_stream_def) do # state is an EventStream
		Agent.start_link(fn -> Naira.EventStream.start(event_stream_def) end) # returns {:ok, pid}
	end

	# API

	def universal_event_stream() do
		event_stream_def = Naira.EventStreamDefService.universal_event_stream_def
	  start_event_stream event_stream_def
  end

  def user_event_stream(user) do
		event_stream_def = Naira.EventStreamDefService.user_event_stream_def user
	  start_event_stream event_stream_def
  end

	def next(pid) do # returns nil when end of stream is hit and the stream restarts from beginning
		Agent.get_and_update(pid, &Naira.EventStream.next(&1) )
	end

	def stop(pid) do
		:ok = Agent.stop(pid)
	end

  # PRIVATE

	defp start_event_stream(event_stream_def) do
		{:ok, pid} = Naira.StreamsSupervisor.start_event_stream event_stream_def
		pid
	end

end 
