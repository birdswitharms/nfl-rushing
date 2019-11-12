defmodule NflRushingWeb.PlayerController do
  use NflRushingWeb, :controller
  alias NflRushing.PlayerService

  def index(conn, _params) do
    redirect(conn, to: "/live")
  end

  def export(conn,
    %{"page" => page,
      "page_size" => page_size,
      "query" => query,
      "sort_by" => sort_by,
      "sort_order" => sort_order}
      ) do

    csv =
      PlayerService.get_stats()
      |> PlayerService.filter(query)
      |> PlayerService.sort(sort_by, String.to_atom(sort_order))
      |> PlayerService.paginate(String.to_integer(page), String.to_integer(page_size))
      |> CSV.encode(headers: true)
      |> Enum.to_list()

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header(
      "content-disposition",
      "attachment;filename=\"Nfl_rushing_stats.csv\""
    )
    |> send_resp(200, csv)

    redirect(conn, to: "/live")
  end
end
