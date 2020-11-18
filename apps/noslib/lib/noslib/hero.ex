defmodule Noslib.Hero do
  @moduledoc false
  alias Noslib.{Helpers, UI, Society}

  @genders BiMap.new(%{
             male: Helpers.encode_int(0),
             female: Helpers.encode_int(1)
           })

  @spec decode_gender(binary) :: atom
  def decode_gender(gender), do: BiMap.get_key(@genders, gender)

  @spec encode_gender(atom) :: iodata
  def encode_gender(gender), do: BiMap.get(@genders, gender)

  @hair_styles BiMap.new(%{
                 a: Helpers.encode_int(0),
                 b: Helpers.encode_int(1),
                 c: Helpers.encode_int(2),
                 d: Helpers.encode_int(3),
                 shave: Helpers.encode_int(4)
               })

  @spec decode_hair_style(binary) :: atom
  def decode_hair_style(hair_style), do: BiMap.get_key(@hair_styles, hair_style)

  @spec encode_hair_style(atom) :: iodata
  def encode_hair_style(hair_style), do: BiMap.get(@hair_styles, hair_style)

  @hair_colors BiMap.new(%{
                 mauve_taupe: Helpers.encode_int(0),
                 cerise: Helpers.encode_int(1),
                 san_marino: Helpers.encode_int(2),
                 affair: Helpers.encode_int(3),
                 dixie: Helpers.encode_int(4),
                 raven: Helpers.encode_int(5),
                 killarney: Helpers.encode_int(6),
                 nutmeg: Helpers.encode_int(7),
                 saddle: Helpers.encode_int(8),
                 red: Helpers.encode_int(9)
               })

  @spec decode_hair_color(binary) :: atom
  def decode_hair_color(hair_color), do: BiMap.get_key(@hair_colors, hair_color)

  @spec encode_hair_color(atom) :: iodata
  def encode_hair_color(hair_color), do: BiMap.get(@hair_colors, hair_color)

  @classes BiMap.new(%{
             adventurer: Helpers.encode_int(0),
             sorcerer: Helpers.encode_int(1),
             archer: Helpers.encode_int(2),
             swordsman: Helpers.encode_int(3),
             martial_artist: Helpers.encode_int(4)
           })

  @spec decode_class(binary) :: atom
  def decode_class(class), do: BiMap.get_key(@classes, class)

  @spec encode_class(atom) :: iodata
  def encode_class(class), do: BiMap.get(@classes, class)

  @type c_info :: %{
          name: binary,
          group_id: pos_integer,
          family_id: pos_integer,
          family_name: binary,
          id: pos_integer,
          name_color: atom,
          gender: atom,
          hair_style: atom,
          hair_color: atom,
          class: atom,
          reputation: atom,
          compliment: pos_integer,
          morph: pos_integer,
          invisible?: boolean,
          family_level: pos_integer,
          morph_upgrade?: boolean,
          arena_winner?: boolean
        }

  def encode_c_info(c_info) do
    Helpers.encode_list([
      c_info.name,
      "-",
      Helpers.encode_int(c_info.group_id),
      Helpers.encode_int(c_info.family_id),
      c_info.family_name,
      Helpers.encode_int(c_info.id),
      UI.encode_name_color(c_info.name_color),
      encode_gender(c_info.gender),
      encode_hair_style(c_info.hair_style),
      encode_hair_color(c_info.hair_color),
      encode_class(c_info.class),
      Society.encode_reputation(c_info.reputation),
      Helpers.encode_int(c_info.compliment),
      Helpers.encode_int(c_info.morph),
      Helpers.encode_bool(c_info.invisible?),
      Helpers.encode_int(c_info.family_level),
      Helpers.encode_bool(c_info.morph_upgrade?),
      Helpers.encode_bool(c_info.arena_winner?)
    ])
  end

  @type tit :: %{
          class: atom,
          name: binary
        }

  def encode_tit(tit) do
    Helpers.encode_list([
      tit.class |> to_string |> String.capitalize(),
      tit.name
    ])
  end

  @type fd :: %{
          reputation: atom,
          dignity: atom
        }

  def encode_fd(fd) do
    Helpers.encode_list([
      Society.encode_reputation(fd.reputation),
      Helpers.encode_int(UI.dignity_icon(fd.reputation)),
      Society.encode_dignity(fd.dignity),
      Helpers.encode_int(UI.reputation_icon(fd.dignity))
    ])
  end

  @type lev :: %{
          level: pos_integer,
          job_level: pos_integer,
          job_xp: pos_integer,
          xp_max: pos_integer,
          job_xp_max: pos_integer,
          reputation: atom,
          cp: pos_integer,
          hero_xp: pos_integer,
          hero_level: pos_integer,
          hero_xp_max: pos_integer
        }

  def encode_lev(lev) do
    Helpers.encode_list([
      Helpers.encode_int(lev.level),
      Helpers.encode_int(lev.job_level),
      Helpers.encode_int(lev.job_xp),
      Helpers.encode_int(lev.xp_max),
      Helpers.encode_int(lev.job_xp_max),
      Society.encode_reputation(lev.reputation),
      Helpers.encode_int(lev.cp),
      Helpers.encode_int(lev.hero_xp),
      Helpers.encode_int(lev.hero_level),
      Helpers.encode_int(lev.hero_xp_max)
    ])
  end
end