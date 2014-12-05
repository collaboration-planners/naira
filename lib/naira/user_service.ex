defmodule Naira.UserService do
	@moduledoc """
 User service.
"""

	require Logger
	use DB
  @naira_id 1


	# API

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
    add_user(email: naira.email, name: naira.name, password: "Quechua59" )
  end

  def add_user([email: email, name: name, password: password]) do
		stored_user = get_user_with_email email
    if stored_user == nil do
			Amnesia.transaction do
				user = user(email: email, name: name)
				User.add user
				added_user = get_user_with_email email # now with id set
				Credentials.write %Credentials{user_id: added_user.id, password: password}
				Naira.EventManager.user_added added_user
				added_user
      end
    else
			IO.puts "User with email #{email} already exists"
			stored_user
    end
  end

	def destroy_user(id) do
		Amnesia.transaction do
			User.destroy id
			Credentials.destroy user_id: id
			# TODO raise event?
		end
	end

	def is_naira(user) do
		user.id == @naira_id
  end

	def user([email: email, name: name]) do
		%User{email: email, name: name, assignments: [], vouchers: []}
  end

  defp user_naira() do
		%User{email: "naira@collaboration-planners.com", name: "Naira", vouchers: [], assignments: []}
  end

  def naira_id() do
		@naira_id
  end

  def set_api_key([id: user_id, email: email, password: password]) do
		user = authenticate email: email, password: password
    if user !== nil and user.id == user_id do 
		    result = Credentials.set_api_key user_id: user.id
				case result do
					{:ok, api_key} -> Naira.EmailService.email_api_key user: user, api_key: api_key
												%{api_key: api_key}
						_ -> Logger.warn "Failed to set the API key of #{inspect user}"
								 result
				end
    else
			%{:error => :not_found}
    end
  end

	def reset_password(user) do
		new_password = generate_password
		result = Credentials.set_password user_id: user.id, password: new_password
		case result do
			:ok -> Naira.EmailService.email_password user: user, password: new_password
			       :ok
						 _ -> Logger.warn "Failed to reset the password of #{inspect user}"
									result
    end
  end

	def change_password([email: email, password: password, new_password: new_password]) do
		user = authenticate email: email, password: password
    if user !== nil do
			:ok = Credentials.update_password user_id: user.id, password: new_password
			Naira.EmailService.password_changed user: user
      :ok
    else
      Logger.warn "Failed to change password of #{email}"
			{:error, :authentication}
    end
  end

	def authenticate([email: email, api_key: api_key]) do
		user = get_user_with_email email
		if user != nil do
			credentials = Credentials.get user_id: user.id
			if api_key !== nil and api_key != "" and credentials.api_key == api_key do
				user
      else
				nil
      end
		else
      nil
		end
	end
	def authenticate([email: email, password: password]) do
		user = get_user_with_email email
		if user != nil do
			credentials = Credentials.get user_id: user.id
			if password != nil and password != "" and credentials.password == password do
				user
      else
				nil
      end
		else
      nil
		end
	end
 
  def verify_key(api_key) do
		api_key !== nil and Credentials.key_exists? api_key
  end

	# PRIVATE

	defp generate_password() do
		Enum.map(1..8, fn(_) -> :random.uniform(26) + 96 end) |> to_string
  end

end 
