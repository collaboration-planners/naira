defmodule Naira.Mixfile do
  use Mix.Project

  def project do
    [app: :naira,
     version: "0.0.1",
     elixir: "~> 1.0.0",
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [application: [:logger], mod: {Naira, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [{:timex, "~>0.13.1"}, 
		 {:geo, "~> 0.8.0"},
#		 { :uuid, "~> 0.1.5" }, 
		 {:amnesia, github: "meh/amnesia", tag: :master}
		]
  end
end
