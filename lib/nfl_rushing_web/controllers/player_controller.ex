defmodule NflRushingWeb.PlayerController do
  use NflRushingWeb, :controller

  def index(conn, _params) do
    # stats = PlayerService.get_stats()

    # render(conn, "index.html", stats: stats)
    live_render(conn, NflRushingWeb.PlayerLive, session: %{}, router: NflRushingWeb.Router)
  end
end
