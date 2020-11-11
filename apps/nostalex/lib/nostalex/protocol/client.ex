defmodule Nostalex.Protocol.Client do
  @moduledoc """
  Client specific response.
  """

  alias Nostalex.Protocol.Helpers

  @type reason ::
          :outdated_client
          | :unexpected_error
          | :maintenance
          | :session_already_used
          | :unvalid_credentials
          | :cant_authenticate
          | :citizen_blacklisted
          | :country_blacklisted
          | :bad_case

  @type error :: %{reason: reason()}

  @type info :: %{message: bitstring}

  @spec pack_failc(error) :: iodata
  def pack_failc(param) do
    Helpers.pack_list(["failc", pack_reason(param.reason)])
  end

  @spec pack_info(info) :: iodata
  def pack_info(param) do
    Helpers.pack_list(["info", param.message])
  end

  @spec pack_reason(reason) :: iodata
  defp pack_reason(:outdated_client), do: Helpers.pack_number(1)
  defp pack_reason(:unexpected_error), do: Helpers.pack_number(2)
  defp pack_reason(:maintenance), do: Helpers.pack_number(3)
  defp pack_reason(:session_already_used), do: Helpers.pack_number(4)
  defp pack_reason(:unvalid_credentials), do: Helpers.pack_number(5)
  defp pack_reason(:cant_authenticate), do: Helpers.pack_number(6)
  defp pack_reason(:citizen_blacklisted), do: Helpers.pack_number(7)
  defp pack_reason(:country_blacklisted), do: Helpers.pack_number(8)
  defp pack_reason(:bad_case), do: Helpers.pack_number(9)
end
