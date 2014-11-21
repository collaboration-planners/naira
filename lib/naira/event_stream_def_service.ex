defmodule Naira.EventStreamDefService do

	@moduledoc """
  Naira's event stream service.
  """
	use DB

  def add_universal_event_stream_def() do
		EventStreamDef.add universal_event_stream_def
  end

	def add_user_event_stream_def(user) do
		EventStreamDef.add user_event_stream_def user.id
	end

	def get_all_event_stream_defs() do
     Amnesia.transaction do
			 EventStreamDef.keys |> Enum.map &EventStreamDef.read(&1)
     end 
  end

  def get_event_stream_defs(user) do
			EventStreamDef.get_all(user_id: user.id)
  end

	### PRIVATE

	defp user_event_stream_def(user_id) do
		%EventStreamDef{foundational: true, shared: true, user_id: user_id, source_streams: [], filters: []}
	end

  defp universal_event_stream_def() do
		%EventStreamDef{foundational: true, shared: true, user_id: 0, source_streams: [], filters: []}
	end


end
