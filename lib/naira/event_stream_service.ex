defmodule Naira.EventStreamService do
	@moduledoc """
Event report stream as supervised agent.
"""

	def start_link(event_stream_def) do
		Agent.start_link(fn -> Naira.EventStream.new(event_stream_def) end) # returns {:ok, pid}
	end

	def next(pid) do
		Agent.get(pid, fn -> &Naira.EventStream.next(&1) end)
	end

	def stop(pid) do
		Agent.stop(pid)
	end

end 
