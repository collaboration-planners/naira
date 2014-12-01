defmodule Naira.EventStreamService do
	@moduledoc """
Event report stream as supervised agent.
"""

	# API

	# Called by supervisor
	def start_link(name, event_stream_def) do # state is an EventStream
		Agent.start_link(fn -> Naira.EventStream.start(event_stream_def) end, [name: name]) # returns {:ok, pid}
	end

	def universal_event_stream() do
		event_stream_def = Naira.EventStreamDefService.universal_event_stream_def
	  start_event_stream event_stream_def
  end

  def user_event_stream(user) do
		event_stream_def = Naira.EventStreamDefService.user_event_stream_def user
	  start_event_stream event_stream_def
  end

	def fail(name) do
		Agent.get(name, &(&1 / 3))
  end

	def next(name) do # returns nil when end of stream is hit and the stream restarts from beginning
		Agent.get_and_update(name, &Naira.EventStream.next(&1) )
	end

	def stop(name) do
		Agent.stop(name)
		Naira.AtomPool.release name
	end

  # PRIVATE

	defp start_event_stream(event_stream_def) do
		name = Naira.AtomPool.take
		{:ok, _pid} = Naira.StreamsSupervisor.start_event_stream(name, event_stream_def)
		name
	end

end 
