# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the router
config :phoenix, Naira.Router,
  url: [host: "localhost"],
  http: [port: System.get_env("PORT")],
  https: false,
  secret_key_base: "YObhEXANkmWHwDMJ7bCuP5rYvES1KW3HBKhejDsz/Z6/gnLiDxX4rGJF083Hlc34TMMhesCRiV62aPJXhCs1zA==",
  catch_errors: true,
  debug_errors: false,
  error_controller: Naira.PageController

# Session configuration
config :phoenix, Naira.Router,
  session: [store: :cookie,
            key: "_naira_key"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
