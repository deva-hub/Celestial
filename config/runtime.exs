import Config

# Configure the database
config :celestial, Celestial.Repo,
  username: System.get_env("POSTGRES_USER", "celestial"),
  password: System.get_env("POSTGRES_PASSWORD", "celestial"),
  hostname: System.get_env("POSTGRES_HOST", "localhost")

# Configure Nostale channel
world = System.get_env("CELESTIAL_WORLD", "1") |> String.to_integer()
channel = System.get_env("CELESTIAL_CHANNEL", "1") |> String.to_integer()

# Configure Celestial portal host
hostname =
  case System.get_env("CELESTIAL_PORTAL_HOST", "0.0.0.0")
       |> to_charlist()
       |> :inet.parse_address() do
    {:ok, hostname} ->
      hostname

    {:error, _} ->
      raise """
      environment variable CELESTIAL_PORTAL_HOST is not a valid hostname.
      Channel need a valid hostname to broadcast the current game server hostname.
      """
  end

# Configure Celestial portal port
port =
  case System.get_env("PORT") do
    nil ->
      System.get_env("CELESTIAL_PORTAL_PORT", "4124") |> String.to_integer()

    port ->
      port |> String.to_integer()
  end

config :celestial_portal,
  world: world,
  channel: channel,
  hostname: hostname,
  port: port

# Configure Celestial gateway port
config :celestial_gateway,
  port: System.get_env("CELESTIAL_GATEWAY_PORT", "4123") |> String.to_integer()

# Don't forget to configure the url hostto something
# meaningful, Phoenix uses this information when
# generating URLs.
config :celestial_web, CelestialWeb.Endpoint,
  url: [
    hostname: System.get_env("HOST", "0.0.0.0"),
    port: System.get_env("CELESTIAL_API_PORT", "4000") |> String.to_integer()
  ]

case config_env() do
  :dev ->
    # Configure the database
    config :celestial, Celestial.Repo, database: System.get_env("POSTGRES_DB", "celestial_dev")

  :test ->
    # The MIX_TEST_PARTITION environment variable can be used
    # to provide built-in test partitioning in CI environment.
    # Run `mix help test` for more information.
    config :celestial, Celestial.Repo,
      database:
        System.get_env("POSTGRES_DB", "celestial_test#{System.get_env("MIX_TEST_PARTITION")}"),
      pool: Ecto.Adapters.SQL.Sandbox

  :prod ->
    # Configures the endpoint
    secret_key_base =
      System.get_env("CELESTIAL_SECRET_KEY_BASE") ||
        raise """
        environment variable CELESTIAL_SECRET_KEY_BASE is missing.
        You can generate one by calling: mix phx.gen.secret
        """

    config :celestial_web, CelestialWeb.Endpoint,
      http: [transport_options: [socket_opts: [:inet6]]],
      secret_key_base: secret_key_base,
      server: true

    # Configures the database
    config :celestial, Celestial.Repo,
      database: System.get_env("POSTGRES_DB", "celestial"),
      pool_size: System.get_env("POOL_SIZE", "10") |> String.to_integer()
end
