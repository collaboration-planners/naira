defmodule Naira.User do
	@moduledoc """
  Struct for a NAIRA user.
  """
	@derive Access

	defstruct id: nil, email: "", password: "", name: "", location: nil, assignments: [], vouchers: []
	
	def new([email: email, password: password, name: name]) do
		%Naira.User{email: email, password: password, name: name}
	end

end
