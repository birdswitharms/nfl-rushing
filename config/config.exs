# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :nfl_rushing,
  ecto_repos: [NflRushing.Repo]

# Configures the endpoint
config :nfl_rushing, NflRushingWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "CmF86Iv1HuUycochP8LF0BmdZbCFhAKcKdN5SiDRewYM/oYpsV5czc4az/c0xxeO",
  render_errors: [view: NflRushingWeb.ErrorView, accepts: ~w(html json)],
  live_view: [
    signing_salt: "srG56gWCkmJYmKh8Mz3cETJzsKSbSu6f"
  ],
  pubsub: [name: NflRushing.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# enable live view
config :phoenix,
  template_engines: [leex: Phoenix.LiveView.Engine]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
