defmodule Naira.EventStreamDefService do

	@moduledoc """
  Naira's event stream definition service.
  """
	use DB

  # API

	@spec add(%EventStreamDef{}) :: %EventStreamDef{}
  @doc "Stores an event stream def"
	def add(event_stream_def) do
		EventStreamDef.add event_stream_def
  end

	@spec remove(%EventStreamDef{}) :: :ok
	@doc "Remove an event stream definition"
  def remove(event_stream_def) do
		EventStreamDef.destroy([id: event_stream_def.id])
  end

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

  @spec get_all() :: [%EventStreamDef{}]
	@doc "Get all event stream definitions"
	def get_all() do
     Amnesia.transaction do
			 EventStreamDef.keys |> Enum.map &EventStreamDef.read(&1)
     end 
  end

  @spec get_all_by_user(%User{}) :: [%EventStreamDef{}]
	@doc "Get all event stream definitions authored by a given user"
  def get_all_by_user(user) do
			EventStreamDef.get_all(user_id: user.id)
  end

	@spec user_event_stream_def(%User{}) :: %EventStreamDef{}
	@doc "Create a user's event stream definition"
	def user_event_stream_def(user) do
		filter_def = FilterDef.source(user.id)
		%EventStreamDef{description: "All events from #{user.name} (#{user.email})", user_id: user.id, shared: true, source_stream_defs: [], filters: [filter_def]}
	end

	@spec universal_event_stream_def() :: %EventStreamDef{}
	@doc "Create the universal event stream definition"
  def universal_event_stream_def() do
		%EventStreamDef{description: "All events", user_id: 1, shared: true, source_stream_defs: [], filters: []}
	end

  @spec properties_event_stream_def([user: %User{}, filter_options: %FilterOptions{}]) :: %EventStreamDef{}
  @doc "Create an event stream that filters event reports on their properties"
  def properties_event_stream_def([user: user, filter_options: filter_options]) do
		filter_def = FilterDef.new([type: PropertyFilter.type, options: filter_options])
		%EventStreamDef{description: "Ad hoc event stream", user_id: user.id, shared: false, source_stream_defs: [], filters: [filter_def]}
  end

	@spec get_all_visible(%User{}) :: [%EventStreamDef{}]
	@doc "Get all event stream defs visible to a given user"
	def get_all_visible(user) do
	  Enum.filter(get_all, &visible?(&1, user)) # TODO - optimize
  end

	@spec visible?(%EventStreamDef{}, %User{}) :: boolean
	@doc "Whether an event stream definition is visible to a given user"
	def visible?(event_stream_def, user) do
		event_stream_def.shared or event_stream_def.user_id === user.id
	end

  @spec get_visible(non_neg_integer, %User{}) :: %EventStreamDef{} | nil
	@doc "Get event stream definition with given id if visible to given user"
	def get_visible(id, user) do
		event_stream_def = EventStreamDef.get(id)
    if event_stream_def !== nil and visible?(event_stream_def, user) do
			event_stream_def
    else
      nil
    end
  end

end
