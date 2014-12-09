defmodule Naira.EventStreamService do
	@moduledoc """
Naira's event stream service. Generates and managed each event report stream as a supervised agent.
"""

	use DB

	# API

	@spec start_link(atom, %EventStreamDef{}) :: {:ok, pid} | {:error, {:already_started, pid} | term}
  @doc "Starts an agent holding an event stream as its state. Invoked by the streams supervisor."
	def start_link(name, event_stream_def) do # state is an EventStream
		Agent.start_link(fn -> Naira.EventStream.start(event_stream_def) end, [name: name]) # returns {:ok, pid}
	end

	@spec universal_event_stream() :: atom
	@doc "Starts a universal event stream"
	def universal_event_stream() do
		event_stream_def = Naira.EventStreamDefService.universal_event_stream_def
	  start_event_stream event_stream_def
  end

	@spec user_event_stream(%User{}) :: atom
	@doc "Starts a user event stream for a given user."
  def user_event_stream(user) do
		event_stream_def = Naira.EventStreamDefService.user_event_stream_def user
	  start_event_stream event_stream_def
  end

	# For testing
	def fail(name) do
		Agent.get(name, &(&1 / 3))
  end

	@spec next(atom) :: %EventReport{} | nil
  @doc "Gets the next event report from the named event stream and advances it. Nil is returned at the end of the stream that is then restarted."
	def next(name) do # returns nil when end of stream is hit and the stream restarts from beginning
		Agent.get_and_update(name, &Naira.EventStream.next(&1) )
	end

	@spec stop(atom) :: :ok
	@doc "Permanently stops the venet stream and recycles its name (an atom)."
	def stop(name) do
		Agent.stop(name)
		Naira.AtomPool.release name
	end

  # PRIVATE

	# Asks the streams supervisor to start a new event stream as agent using a new or recylced name which is returned.
	defp start_event_stream(event_stream_def) do
		name = Naira.AtomPool.take
		{:ok, _pid} = Naira.StreamsSupervisor.start_event_stream(name, event_stream_def)
		name
	end

end 
