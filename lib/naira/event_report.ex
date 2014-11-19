defmodule Naira.EventReport do
	@moduledoc """
  An event report struct.
  """

	@derive Access
	@user Timex

	defstruct user_id: 0, headline: "", description: "", tags: [], location: nil, date: nil, refs: []

	def new([user_id: user_id, headline: headline]) do
		%Naira.EventReport{user_id: user_id, headline: headline, date: Date.now()}
	end

end
