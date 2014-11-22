defmodule Naira.UserService do
	@moduledoc """
 User service.
"""
	use DB
  @naira_id 1

	def get_all_users() do
    Amnesia.transaction do
			User.keys |> Enum.map &User.read(&1)
    end 
  end

	def get_user_naira() do
		get_user_with_id @naira_id
  end

	def get_user_with_email(email) do
		User.get([email: email])
	end

	def get_user_with_id(id) do 
		User.get([id: id])
	end

	def add_user_naira() do
		naira = user_naira
    add_user(email: naira.email, name: naira.name, password: naira.password)
  end

  def add_user([email: email, name: name, password: password]) do
		stored_user = get_user_with_email email
    if stored_user == nil do
			user = user(email: email, name: name, password: password)
			User.add user
			added_user = get_user_with_email email # now with id set
			Naira.EventManager.user_added added_user
			added_user
    else
			IO.puts "User with email #{email} already exists"
			stored_user
    end
  end

	def is_naira(user) do
		user.id == @naira_id
  end

	def user([email: email, name: name, password: password]) do
		%User{email: email, name: name, password: password, assignments: [], vouchers: []}
  end

  defp user_naira() do
		%User{email: "naira@collaboration-planners.com", password: "DreamCatcher22", name: "Naira", vouchers: [], assignments: []}
  end

  def naira_id() do
		@naira_id
  end

end 
