defmodule NairaTest do
  use ExUnit.Case

  test "OTP processes started" do
    assert is_pid(Process.whereis(:"Elixir.Naira.MainSupervisor")) == true
    assert is_pid(Process.whereis(:"Elixir.Naira.AtomPool")) == true
    assert is_pid(Process.whereis(:"Elixir.Naira.EventManager")) == true
    assert is_pid(Process.whereis(:"Elixir.Naira.StreamsSupervisor")) == true
  end
end
