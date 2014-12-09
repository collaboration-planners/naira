defmodule Naira.UsersController do

	require Logger
	require Naira.WebUtils
  import Naira.WebUtils, only: [key_protected: 3]
	use Phoenix.Controller
	alias Poison, as: JSON

	plug :action

	# Authenticated API
	def index(conn, %{"key" => api_key}) do
		key_protected(conn, api_key) do
			json conn, JSON.encode!(Naira.UserService.get_all_users)
		end
	end

  def show(conn, %{"id" => s_id, "key" => api_key}) do
		key_protected(conn, api_key) do
			id = String.to_integer s_id
			json conn, JSON.encode!(Naira.UserService.get_user_with_id id)
		end
	end

  def show(conn, %{"email" => email, "key" => api_key}) do
		key_protected(conn, api_key) do
			json conn, JSON.encode!(Naira.UserService.get_user_with_email email)
	  end
	end

	def destroy(conn, %{"id" => s_id, "key" => api_key}) do
		key_protected(conn, api_key) do
			id = String.to_integer s_id
			result = Naira.UserService.destroy_user id
			json conn, JSON.encode! result
		end
  end

  # Non-authenticated API

  def create(conn, params) do
		user = Naira.UserService.add_user(email: params["email"],  name: params["name"], password: params["password"])
		Logger.info "Created user #{inspect user}"
		json conn, JSON.encode! user
  end

  def update(conn, %{"id" => s_id, "api_key_for" => email, "password" => password}) do
		user_id = String.to_integer s_id
		json conn, JSON.encode!(Naira.UserService.create_api_key id: user_id, email: email, password: password)
  end


end
