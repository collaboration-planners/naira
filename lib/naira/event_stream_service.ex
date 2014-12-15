defmodule Naira.EventStreamService do
	@moduledoc """
Naira's event stream service. Generates and managed each event report stream as a supervised agent.
"""

	use DB

	# API

	@spec start_link(atom, %EventStreamDef{}, %User{}) :: {:ok, pid} | {:error, {:already_started, pid} | term}
  @doc "Starts an agent holding an event stream as its state. Invoked by the streams supervisor."
	def start_link(name, event_stream_def, user) do # state is an EventStream
		Agent.start_link(fn -> Naira.EventStream.start(event_stream_def, user) end, [name: name]) # returns {:ok, pid}
	end

	@spec universal_event_stream(%User{}) :: atom
	@doc "Starts a universal event stream"
	def universal_event_stream(user) do
		event_stream_def = Naira.EventStreamDefService.universal_event_stream_def
	  start_event_stream(event_stream_def, user)
  end

	@spec user_event_stream([source: %User{}, user: %User{}]) :: atom
	@doc "Starts a user event stream for a given user."
  def user_event_stream([source: source, user: user]) do # Shorthand for a properties event stream filtering only on source
		event_stream_def = Naira.EventStreamDefService.user_event_stream_def(source)
	  start_event_stream(event_stream_def, user)
  end

	@spec properties_event_stream([filter_options: %FilterOptions{}, user: %User{}]) :: atom
	@doc "Starts a properties event stream."
  def properties_event_stream([filter_options: filter_options, user: user]) do
		event_stream_def = Naira.EventStreamDefService.properties_event_stream_def([user: user, filter_options: filter_options])
	  start_event_stream(event_stream_def, user)
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
	@doc "Permanently stops the event stream and recycles its name (an atom)."
	def stop(name) do
		event_stream = Agent.get(name, &(&1))
		Agent.stop(name)
		Naira.AtomPool.release name
		# Also stop source streams
		Enum.each(event_stream.sources, &stop(&1))
	end

  # PRIVATE

	# Asks the streams supervisor to start a new event stream as agent using a new or recylced name which is returned.
	defp start_event_stream(event_stream_def, user) do
		name = Naira.AtomPool.take
		{:ok, _pid} = Naira.StreamsSupervisor.start_event_stream(name, event_stream_def, user)
		name
	end

end 
