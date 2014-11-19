defmodule Data do
	@use Geo
	@use Timex
	require Record

	Record.defrecord :user, id: 0, email: "", password: "", name: "", location: nil, assignments: [], vouchers: []

	Record.defrecord :assignment, title: "", organization: ""

	Record.defrecord :event_report, user_id: 0, headline: "", description: "", tags: [], location: nil, date: nil, refs: []

	Record.defrecord :location, geoname: "", geopoint: nil

	Record.defrecord :voucher, user_id: 0, trusted: true, date: nil

	def new_user do
		user
  end

	def new_event_report user_id: user_id, headline: headline do
		event_report user_id: user_id, headline: headline, date: Date.now
		end

	def new_assignment title: title, organization: org do
		assignment title: title, organization: org
	end

  def new_voucher user_id: user_id, trusted: trusted  do
		voucher user_id: user_id, trusted: trusted, date: Date.now
	end

	def new_location geoname: geoname do
		location geoname: geoname
  end

	def new_location geopoint: geopoint do
		location geopoint: geopoint
  end

end
