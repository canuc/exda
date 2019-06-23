# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :phoenix_exda_sample,
  ecto_repos: [PhoenixExdaSample.Repo]

# Configures the endpoint
config :phoenix_exda_sample, PhoenixExdaSampleWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "WpcNxCteT6FJMXqLePeTQpF4SZQLwS//b15MtB/69mCxOClPsNmhNTUx2RdFp8o7",
  render_errors: [view: PhoenixExdaSampleWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: PhoenixExdaSample.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :exda, events: [:http_request_processed, :user_index_requested]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
