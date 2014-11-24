defmodule Naira.UsersController do

	use Phoenix.Controller
	alias Poison, as: JSON
	plug :action

	def index(conn, _) do
		json conn, JSON.encode!(Naira.UserService.get_all_users)
	end

  def show(conn, %{"id" => s_id}) do
		id = String.to_integer s_id
		json conn, JSON.encode!(Naira.UserService.get_user_with_id id)
	end

  def show(conn, %{"email" => email}) do
		json conn, JSON.encode!(Naira.UserService.get_user_with_email email)
	end

  def create(conn, params) do
		user = Naira.UserService.add_user(email: params["email"],  name: params["name"], password: params["password"])
		json conn, JSON.encode! user
  end

	def destroy(conn, %{"id" => s_id}) do
		id = String.to_integer s_id
		result = Naira.UserService.destroy_user id
		json conn, JSON.encode! result
  end

end
