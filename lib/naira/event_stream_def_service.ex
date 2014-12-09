defmodule Naira.EventStreamDefService do

	@moduledoc """
  Naira's event stream definition service.
  """
	use DB

  # API

	@spec add_universal_event_stream_def() :: %EventStreamDef{}
	@doc "Add a universal event stream definition"
  def add_universal_event_stream_def() do
		EventStreamDef.add universal_event_stream_def
  end

	@spec add_user_event_stream_def(%User{}) :: %EventStreamDef{}
	@doc "Add a user event stream definition"
	def add_user_event_stream_def(user) do
		EventStreamDef.add user_event_stream_def user
	end

  @spec get_all_event_stream_defs() :: [%EventStreamDef{}]
	@doc "Get all event stream definitions"
	def get_all_event_stream_defs() do
     Amnesia.transaction do
			 EventStreamDef.keys |> Enum.map &EventStreamDef.read(&1)
     end 
  end

  @spec get_event_stream_defs(%User{}) :: [%EventStreamDef{}]
	@doc "Get all event stream definitions authored by a given user"
  def get_event_stream_defs(user) do
			EventStreamDef.get_all(user_id: user.id)
  end

	@spec user_event_stream_def(%User{}) :: %EventStreamDef{}
	@doc "Create a user's event stream definition"
	def user_event_stream_def(user) do
		%EventStreamDef{foundational: true, shared: true, user_id: user.id, source_streams: [], filters: []}
	end

	@spec universal_event_stream_def() :: %EventStreamDef{}
	@doc "Create the universal event stream definition"
  def universal_event_stream_def() do
		%EventStreamDef{foundational: true, shared: true, user_id: 0, source_streams: [], filters: []}
	end


end
