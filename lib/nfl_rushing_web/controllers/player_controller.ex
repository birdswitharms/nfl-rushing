defmodule NflRushingWeb.PlayerController do
  use NflRushingWeb, :controller
  alias NflRushing.PlayerService
  alias NflRushingWeb.PlayerLive

  def index(conn, params) do
    IO.inspect(params, label: :params_export)

    redirect(conn, to: "/live")
  end

  def export(conn,
    %{"page" => page,
      "page_size" => page_size,
      "query" => query,
      "sort_by" => sort_by,
      "sort_order" => sort_order} = params
      ) do

    csv =
      PlayerService.get_stats()
      |> PlayerLive.filter(query)
      |> PlayerLive.sort(sort_by, String.to_atom(sort_order))
      |> PlayerLive.paginate(String.to_integer(page), String.to_integer(page_size))
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
