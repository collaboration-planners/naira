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
		filter_def = FilterDef.source(user.id)
		%EventStreamDef{shared: true, source_stream_defs: [], filters: [filter_def]}
	end

	@spec universal_event_stream_def() :: %EventStreamDef{}
	@doc "Create the universal event stream definition"
  def universal_event_stream_def() do
		%EventStreamDef{user_id: 1, shared: true, user_id: 0, source_stream_defs: [], filters: []}
	end

  @spec properties_event_stream_def([user: %User{}, filter_options: %FilterOptions{}]) :: %EventStreamDef{}
  @doc "Create an event stream that filters event reports on their properties"
  def properties_event_stream_def([user: user, filter_options: filter_options]) do
		filter_def = FilterDef.new([mod: PropertyFilter, options: filter_options])
		%EventStreamDef{user_id: user.id, shared: false, source_stream_defs: [], filters: [filter_def]}
  end

end
