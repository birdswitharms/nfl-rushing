defmodule NflRushingWeb.PlayerController do
  use NflRushingWeb, :controller

  alias NflRushing.PlayerService

  def index(conn, _params) do
    stats = PlayerService.get_stats()

    render(conn, "index.html", stats: stats)
  end
end
