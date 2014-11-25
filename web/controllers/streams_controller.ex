defmodule Naira.StreamsController do

	use Phoenix.Controller
	alias Poison, as: JSON
	plug :action


  def show(conn, %{"id" => s_pid}) do
		pid = string_to_pid s_pid
		next = Naira.EventStreamService.next pid
		json conn, JSON.encode! next
	end

  def create(conn, %{"user" => s_user_id}) do
		user_id = String.to_integer s_user_id
		user = Naira.UserService.get_user_with_id user_id
    if user !== nil do
			s_pid = Naira.EventStreamService.user_event_stream(user) |> pid_to_string
			json conn, JSON.encode! %{pid: s_pid}
    else
			json conn, JSON.encode! nil
    end
  end
  def create(conn, %{"universal" => _}) do
		s_pid =  Naira.EventStreamService.universal_event_stream |> pid_to_string
		json conn, JSON.encode! %{pid: s_pid}
  end

	def destroy(conn, %{"id" => s_pid}) do
		pid = string_to_pid s_pid
		result = Naira.EventStreamService.stop pid
		json conn, JSON.encode! result
  end

	defp string_to_pid(s_pid) do
		[p1,p2,p3] = String.split s_pid, "."
		:c.pid(String.to_integer(p1), String.to_integer(p2), String.to_integer(p3))
  end

  defp pid_to_string(pid) do
		l_pid = :erlang.pid_to_list pid
		List.to_string(l_pid) |> String.lstrip(?<) |> String.rstrip(?>)
	end
end
