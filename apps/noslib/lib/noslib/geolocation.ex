defmodule Noslib.Geolocation do
  @moduledoc false
  alias Noslib.Helpers

  @type at :: %{
          id: pos_integer,
          map_id: pos_integer,
          position_x: pos_integer,
          position_y: pos_integer,
          music_id: pos_integer
        }

  def encode_at(at) do
    Helpers.encode_list([
      Helpers.encode_int(at.id),
      Helpers.encode_int(at.map_id),
      Helpers.encode_int(at.position_x),
      Helpers.encode_int(at.position_y),
      "2",
      "0",
      Helpers.encode_int(at.music_id),
      "-1"
    ])
  end

  @spec decode_walk([binary]) :: {:walk, String.t(), String.t(), String.t()}
  def decode_walk([pos_x, pos_y, checksum, speed]) do
    %{
      position_x: String.to_integer(pos_x),
      position_y: String.to_integer(pos_y),
      speed: String.to_integer(speed),
      checksum: checksum
    }
  end
end