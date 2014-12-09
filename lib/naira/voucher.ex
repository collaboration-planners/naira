defmodule Voucher do
	@moduledoc """
Struct for Naira user voucher: The ids of the trusting and trusted users.
"""
	@derive Access
	@user Timex

	defstruct user_id: nil, trusted: true, date: nil

  @spec new([user_id: non_neg_integer, trusted: non_neg_integer]) :: %Voucher{} 
	@doc "Creates a new voucher"
	def new([user_id: user_id, trusted: trusted]) do
		%Voucher{user_id: user_id, trusted: trusted, date: Date.now()}
	end

end
