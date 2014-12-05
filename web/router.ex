defmodule Naira.Router do
  use Phoenix.Router
 
  scope "/" do
    # Use the default browser stack.
    pipe_through :browser

    get "/", Naira.PageController, :index, as: :pages

	end

	scope "/api" do
		pipe_through :api
		
		resources "/events", Naira.EventsController, only: [:index, :show, :create, :destroy]
		resources "/streams", Naira.StreamsController, only: [:create, :show, :destroy]
		resources "/users", Naira.UsersController, only: [:index, :show, :create, :update, :destroy]
  end
end
