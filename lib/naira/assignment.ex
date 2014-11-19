defmodule Naira.Assignment do
	@moduledoc """
  A user assignment doc
  """
	@derive Access

	defstruct title: "", organization: ""

	def new([title: title, organization: org]) do
		%Naira.Assignment{title: title, organization: org}
  end

end
