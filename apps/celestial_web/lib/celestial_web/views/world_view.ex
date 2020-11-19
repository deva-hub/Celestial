defmodule CelestialWeb.WorldView do
  use CelestialWeb, :view
  alias CelestialWeb.WorldView

  def render("index.json", %{worlds: worlds}) do
    %{data: render_many(worlds, WorldView, "world.json")}
  end

  def render("show.json", %{world: world}) do
    %{data: render_one(world, WorldView, "world.json")}
  end

  def render("world.json", %{world: world}) do
    %{id: world.id,
      name: world.name}
  end
end
