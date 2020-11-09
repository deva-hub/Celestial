defmodule CelestialGateway.Protocol do
  @moduledoc false
  @behaviour :ranch_protocol

  require Logger
  alias Celestial.Accounts

  @impl true
  def start_link(ref, _, transport, opts) do
    start_link(ref, transport, opts)
  end

  def start_link(ref, transport, opts \\ []) do
    {:ok, :proc_lib.spawn_link(__MODULE__, :connection_process, [{self(), ref, transport, opts}])}
  end

  def connection_process({parent, ref, transport, opts}) do
    {:ok, socket} = :ranch.handshake(ref)
    init(parent, socket, transport, opts)
  end

  defp init(_parent, socket, transport, _opts) do
    loop(%{socket: socket, transport: transport})
  end

  defp loop(state) do
    %{socket: socket} = state

    :ok = state.transport.setopts(state.socket, active: :once)
    {ok, closed, error} = state.transport.messages()

    receive do
      {^ok, ^socket, ciphertext} ->
        plaintext = NostalexCrypto.Gateway.decrypt(ciphertext)

        Logger.info(Enum.intersperse(["PACKET", plaintext], " "))

        plaintext
        |> Nostalex.parse()
        |> handle_packet(state)

      {^error, ^socket, reason} ->
        terminate(state, {:socket_error, reason})

      {^closed, ^socket} ->
        terminate(state, {:socket_error, :closed})
    end
  end

  defp handle_packet({:nos0575, _, email, cipher_password, _, client_version}, state) do
    client_version = CelestialGateway.Helpers.normalize_version(client_version)
    password = NostalexCrypto.Gateway.decrypt_password(cipher_password)
    ip = get_ip_address(state)

    with :ok <- validate_client_version(client_version),
         {:ok, uid} <- generate_uid_by_email_and_password(ip, email, password) do
      send_packet(state, Nostalex.Gateway.pack_nstest(%{uid: uid, channels: []}))
      terminate(state, :normal)
    else
      {:error, :outdated_client} ->
        send_packet(state, Nostalex.Client.pack_failc(%{reason: :outdated_client}))
        loop(state)

      {:error, :unvalid_credentials} ->
        send_packet(state, Nostalex.Client.pack_failc(%{reason: :unvalid_credentials}))
        loop(state)
    end
  rescue
    e ->
      send_packet(state, Nostalex.Client.pack_failc(%{reason: :bad_case}))
      reraise e, __STACKTRACE__
  end

  defp handle_packet(_, state) do
    loop(state)
  end

  defp send_packet(state, packet) do
    ciphertext_packet =
      packet
      |> Enum.join(" ")
      |> NostalexCrypto.Gateway.encrypt()

    :ok = state.transport.send(state.socket, ciphertext_packet)
  end

  defp terminate(_state, reason) do
    exit({:shutdown, reason})
  end

  defp validate_client_version(version) do
    case Application.get_env(:gateway, :client_requirement) do
      nil ->
        :ok

      requirement ->
        validate_client_verion_requirement(version, requirement)
    end
  end

  defp validate_client_verion_requirement(version, requirement) do
    if Version.match?(version, requirement) do
      :ok
    else
      {:error, :outdated_client}
    end
  end

  defp generate_uid_by_email_and_password(ip, email, password) do
    if identity = Accounts.get_identity_by_email_and_password(email, password) do
      {:ok, Accounts.generate_identity_uid_token(ip, identity)}
    else
      {:error, :unvalid_credentials}
    end
  end

  defp get_ip_address(state) do
    {:ok, {ip, _}} = state.transport.peername(state.socket)
    ip |> :inet.ntoa() |> to_string()
  end
end
