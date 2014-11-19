defmodule Naira.Voucher do
	@moduledoc """
Struct for Naira user voucher.
"""
	@derive Access
	@user Timex

	defstruct user_id: nil, trusted: true, date: nil

	def new([user_id: user_id, trusted: trusted]) do
		%Naira.Voucher{user_id: user_id, trusted: trusted, date: Date.now()}
	end

end
