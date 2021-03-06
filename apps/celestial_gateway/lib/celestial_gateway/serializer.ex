defmodule CelestialGateway.Serializer do
  @moduledoc false
  @behaviour Nostalex.Socket.Serializer

  alias CelestialGateway.Crypto
  alias Nostalex.Socket.{Broadcast, Message}

  @impl true
  def fastlane!(%Broadcast{} = msg) do
    data = Noslib.encode([msg.event, msg.payload])
    {:socket_push, :plain, data |> IO.iodata_to_binary() |> Crypto.encrypt()}
  end

  @impl true
  def encode!(%Message{} = msg) do
    data = Noslib.encode([msg.event, msg.payload])
    {:socket_push, :plain, data |> IO.iodata_to_binary() |> Crypto.encrypt()}
  end

  @impl true
  def decode!(raw_message, _opts) do
    [id, event, payload | _] = raw_message |> Crypto.decrypt() |> Noslib.decode()
    %Message{event: event, payload: payload, id: id}
  end
end
