defmodule Assignment do
	@moduledoc """
  A user assignment struct: A title in an organization.
  """
	@derive Access

	defstruct title: "", organization: ""

	@spec new([title: String.t, organization: String.t]) :: %Assignment{}
  @doc "Creates a new assignment"
	def new([title: title, organization: org]) do
		%Assignment{title: title, organization: org}
  end

end
