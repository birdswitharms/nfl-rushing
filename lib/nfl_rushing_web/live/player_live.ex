defmodule NflRushingWeb.PlayerLive do
  use Phoenix.LiveView

  alias NflRushing.PlayerService
  alias NflRushingWeb.Router.Helpers, as: Routes

  def render(assigns) do
    ~L"""
    <section class="phx-hero">
    <h1>Welcome to - NFL Rushing Stats</h1>

    </section>
    <form phx-change="search"><input type="text" name="query" value="<%= @query %>" placeholder="Search..." /></form>

    <button phx-click="export">Export CSV</button>

    <table>
      <thead>
        <tr class="column">
          <th phx-click="sort" phx-value-player="Player">
            Player
            <%= sort_order_icon("Player", @sort_by, @sort_order) %>
          </th>
          <th phx-click="sort" phx-value-team="Team">
            Team
            <%= sort_order_icon("Team", @sort_by, @sort_order) %>
          </th>
          <th phx-click="sort" phx-value-pos="Pos">
            Position
            <%= sort_order_icon("Pos", @sort_by, @sort_order) %>
          </th>
          <th phx-click="sort" phx-value-att-g="Att/G">
            Rushing Attempts / Game
            <%= sort_order_icon("Att/G", @sort_by, @sort_order) %>
          </th>
          <th phx-click="sort" phx-value-att="Att">
            Rushing Attempts
            <%= sort_order_icon("Att", @sort_by, @sort_order) %>
          </th>
          <th phx-click="sort" phx-value-yds="Yds">
            Total Rushing Yards
            <%= sort_order_icon("Yds", @sort_by, @sort_order) %>
          </th>
          <th phx-click="sort" phx-value-avg="Avg">
            Rushing Avg Yards / Attempt
            <%= sort_order_icon("Avg", @sort_by, @sort_order) %>
          </th>
          <th phx-click="sort" phx-value-yds-g="Yds/G">
            Rushing Yards / Game
            <%= sort_order_icon("Yds/G", @sort_by, @sort_order) %>
          </th>
          <th phx-click="sort" phx-value-td="TD">
            Total Rushing Touchdowns
            <%= sort_order_icon("TD", @sort_by, @sort_order) %>
          </th>
          <th phx-click="sort" phx-value-lng="Lng">
            Longest Rush
            <%= sort_order_icon("Lng", @sort_by, @sort_order) %>
          </th>
          <th phx-click="sort" phx-value-1st="1st">
            Rushing First Downs
            <%= sort_order_icon("1st", @sort_by, @sort_order) %>
          </th>
          <th phx-click="sort" phx-value-1st%="1st%">
            Rushing First Down %
            <%= sort_order_icon("1st%", @sort_by, @sort_order) %>
          </th>
          <th phx-click="sort" phx-value-20="20+">
            Rushing 20+ Yards Each
            <%= sort_order_icon("20+", @sort_by, @sort_order) %>
          </th>
          <th phx-click="sort" phx-value-40="40+">
            Rushing 40+ Yards Each
            <%= sort_order_icon("40+", @sort_by, @sort_order) %>
          </th>
          <th phx-click="sort" phx-value-fum="FUM">
            Rushing Fumbles
            <%= sort_order_icon("FUM", @sort_by, @sort_order) %>
          </th>
        </tr>
      </thead>
      <tbody>
      <%= for row <- rows(assigns) do %>
        <tr>
          <td><%= row["Player"] %></td>
          <td><%= row["Team"] %></td>
          <td><%= row["Pos"] %></td>
          <td><%= row["Att"] %></td>
          <td><%= row["Att/G"] %></td>
          <td><%= row["Yds"] %></td>
          <td><%= row["Avg"] %></td>
          <td><%= row["Yds/G"] %></td>
          <td><%= row["TD"] %></td>
          <td><%= row["Lng"] %></td>
          <td><%= row["1st"] %></td>
          <td><%= row["1st%"] %></td>
          <td><%= row["20+"] %></td>
          <td><%= row["40+"] %></td>
          <td><%= row["FUM"] %></td>
        </tr>
      <% end %>
      </tbody>
    </table>


    <nav class="float-left">
      <%= for page <- (1..number_of_pages(assigns)) do %>
        <%= if page == @page do %>
          <%= page %>
        <% else %>
          <a href="#" phx-click="goto-page" phx-value-page=<%= page %>><%= page %></a>
        <% end %>
      <% end %>
    </nav>

    <form phx-change="change-page-size" class="float-right">
      <select name="page_size">
        <%= for page_size <- [5, 10, 25, 50] do %>
          <option value="<%= page_size %>" <%= page_size == @page_size && "selected" || "" %>>
            <%= page_size %> per page
          </option>
        <% end %>
      </select>
    </form>
    """
  end

  def mount(_session, socket) do
    {:ok, assign(socket, data: PlayerService.get_stats(), query: nil, sort_by: "Player", sort_order: :desc, page: 1, page_size: 10)}
  end

  def handle_params(params, _url, socket) do
    query = params["query"]
    sort_by =
      case params["sort_by"] do
        sort_by when sort_by in ~w(Player Team Pos Att/G Att Yds Avg Yds/G TD Lng 1st 1st% 20 40 FUM) ->
          params["sort_by"]
        _ ->
          "Player"
      end
    sort_order = params["sort_order"] == "asc" && :asc || :desc
    page = String.to_integer(params["page"] || "1")
    page_size = String.to_integer(params["page_size"] || "10")
    {:noreply, assign(socket, query: query, sort_by: sort_by, sort_order: sort_order, page: page, page_size: page_size)}
  end

  def handle_event("search", %{"query" => query}, socket) do
    {:noreply, redirect_with_attrs(socket, query: query, page: 1)}
  end

  # When the column that is used for sorting is clicked again, we reverse the sort order
  def handle_event("sort", %{"player" => player}, %{assigns: %{sort_by: sort_by, sort_order: :asc}} = socket) when player == sort_by do
    {:noreply, assign(socket, sort_by: sort_by, sort_order: :desc)}
  end
  def handle_event("sort", %{"player" => player}, %{assigns: %{sort_by: sort_by, sort_order: :desc}} = socket) when player == sort_by do
    {:noreply, redirect_with_attrs(socket, sort_by: sort_by, sort_order: :asc)}
  end
  def handle_event("sort", %{"team" => team}, %{assigns: %{sort_by: sort_by, sort_order: :asc}} = socket) when team == sort_by do
    {:noreply, assign(socket, sort_by: sort_by, sort_order: :desc)}
  end
  def handle_event("sort", %{"team" => team}, %{assigns: %{sort_by: sort_by, sort_order: :desc}} = socket) when team == sort_by do
    {:noreply, redirect_with_attrs(socket, sort_by: sort_by, sort_order: :asc)}
  end
  def handle_event("sort", %{"pos" => pos}, %{assigns: %{sort_by: sort_by, sort_order: :asc}} = socket) when pos == sort_by do
    {:noreply, assign(socket, sort_by: sort_by, sort_order: :desc)}
  end
  def handle_event("sort", %{"pos" => pos}, %{assigns: %{sort_by: sort_by, sort_order: :desc}} = socket) when pos == sort_by do
    {:noreply, redirect_with_attrs(socket, sort_by: sort_by, sort_order: :asc)}
  end
  def handle_event("sort", %{"att" => att}, %{assigns: %{sort_by: sort_by, sort_order: :asc}} = socket) when att == sort_by do
    {:noreply, assign(socket, sort_by: sort_by, sort_order: :desc)}
  end
  def handle_event("sort", %{"att" => att}, %{assigns: %{sort_by: sort_by, sort_order: :desc}} = socket) when att == sort_by do
    {:noreply, redirect_with_attrs(socket, sort_by: sort_by, sort_order: :asc)}
  end
  def handle_event("sort", %{"att-g" => attg}, %{assigns: %{sort_by: sort_by, sort_order: :asc}} = socket) when attg == sort_by do
    {:noreply, assign(socket, sort_by: sort_by, sort_order: :desc)}
  end
  def handle_event("sort", %{"att-g" => attg}, %{assigns: %{sort_by: sort_by, sort_order: :desc}} = socket) when attg == sort_by do
    {:noreply, redirect_with_attrs(socket, sort_by: sort_by, sort_order: :asc)}
  end
  def handle_event("sort", %{"avg" => avg}, %{assigns: %{sort_by: sort_by, sort_order: :asc}} = socket) when avg == sort_by do
    {:noreply, assign(socket, sort_by: sort_by, sort_order: :desc)}
  end
  def handle_event("sort", %{"avg" => avg}, %{assigns: %{sort_by: sort_by, sort_order: :desc}} = socket) when avg == sort_by do
    {:noreply, redirect_with_attrs(socket, sort_by: sort_by, sort_order: :asc)}
  end
  def handle_event("sort", %{"yds-g" => ydsg}, %{assigns: %{sort_by: sort_by, sort_order: :asc}} = socket) when ydsg == sort_by do
    {:noreply, assign(socket, sort_by: sort_by, sort_order: :desc)}
  end
  def handle_event("sort", %{"yds-g" => ydsg}, %{assigns: %{sort_by: sort_by, sort_order: :desc}} = socket) when ydsg == sort_by do
    {:noreply, redirect_with_attrs(socket, sort_by: sort_by, sort_order: :asc)}
  end
  def handle_event("sort", %{"yds" => yds}, %{assigns: %{sort_by: sort_by, sort_order: :asc}} = socket) when yds == sort_by do
    {:noreply, assign(socket, sort_by: sort_by, sort_order: :desc)}
  end
  def handle_event("sort", %{"yds" => yds}, %{assigns: %{sort_by: sort_by, sort_order: :desc}} = socket) when yds == sort_by do
    {:noreply, redirect_with_attrs(socket, sort_by: sort_by, sort_order: :asc)}
  end
  def handle_event("sort", %{"td" => td}, %{assigns: %{sort_by: sort_by, sort_order: :asc}} = socket) when td == sort_by do
    {:noreply, assign(socket, sort_by: sort_by, sort_order: :desc)}
  end
  def handle_event("sort", %{"td" => td}, %{assigns: %{sort_by: sort_by, sort_order: :desc}} = socket) when td == sort_by do
    {:noreply, redirect_with_attrs(socket, sort_by: sort_by, sort_order: :asc)}
  end
  def handle_event("sort", %{"lng" => lng}, %{assigns: %{sort_by: sort_by, sort_order: :asc}} = socket) when lng == sort_by do
    {:noreply, assign(socket, sort_by: sort_by, sort_order: :desc)}
  end
  def handle_event("sort", %{"lng" => lng}, %{assigns: %{sort_by: sort_by, sort_order: :desc}} = socket) when lng == sort_by do
    {:noreply, redirect_with_attrs(socket, sort_by: sort_by, sort_order: :asc)}
  end
  def handle_event("sort", %{"1st" => first}, %{assigns: %{sort_by: sort_by, sort_order: :asc}} = socket) when first == sort_by do
    {:noreply, assign(socket, sort_by: sort_by, sort_order: :desc)}
  end
  def handle_event("sort", %{"1st" => first}, %{assigns: %{sort_by: sort_by, sort_order: :desc}} = socket) when first == sort_by do
    {:noreply, redirect_with_attrs(socket, sort_by: sort_by, sort_order: :asc)}
  end
  def handle_event("sort", %{"1st%" => firstpercent}, %{assigns: %{sort_by: sort_by, sort_order: :asc}} = socket) when firstpercent == sort_by do
    {:noreply, assign(socket, sort_by: sort_by, sort_order: :desc)}
  end
  def handle_event("sort", %{"1st%" => firstpercent}, %{assigns: %{sort_by: sort_by, sort_order: :desc}} = socket) when firstpercent == sort_by do
    {:noreply, redirect_with_attrs(socket, sort_by: sort_by, sort_order: :asc)}
  end
  def handle_event("sort", %{"20" => twenty}, %{assigns: %{sort_by: _sort_by, sort_order: :asc}} = socket) when twenty == "20+" do
    {:noreply, assign(socket, sort_by: "20+", sort_order: :desc)}
  end
  def handle_event("sort", %{"20" => twenty}, %{assigns: %{sort_by: _sort_by, sort_order: :desc}} = socket) when twenty == "20+" do
    {:noreply, redirect_with_attrs(socket, sort_by: "40+", sort_order: :asc)}
  end
  def handle_event("sort", %{"40" => forty}, %{assigns: %{sort_by: _sort_by, sort_order: :asc}} = socket) when forty == "40+" do
    {:noreply, assign(socket, sort_by: "40+", sort_order: :desc)}
  end
  def handle_event("sort", %{"40" => forty}, %{assigns: %{sort_by: _sort_by, sort_order: :desc}} = socket) when forty == "40+" do
    {:noreply, redirect_with_attrs(socket, sort_by: "40+", sort_order: :asc)}
  end
  def handle_event("sort", %{"fum" => fum}, %{assigns: %{sort_by: sort_by, sort_order: :asc}} = socket) when fum == sort_by do
    {:noreply, assign(socket, sort_by: sort_by, sort_order: :desc)}
  end
  def handle_event("sort", %{"fum" => fum}, %{assigns: %{sort_by: sort_by, sort_order: :desc}} = socket) when fum == sort_by do
    {:noreply, redirect_with_attrs(socket, sort_by: sort_by, sort_order: :asc)}
  end

  # A new column has been clicked
  def handle_event("sort", %{"player" => player}, socket) do
    {:noreply, redirect_with_attrs(socket, sort_by: player)}
  end
  def handle_event("sort", %{"team" => team}, socket) do
    {:noreply, redirect_with_attrs(socket, sort_by: team)}
  end
  def handle_event("sort", %{"pos" => pos}, socket) do
    {:noreply, redirect_with_attrs(socket, sort_by: pos)}
  end
  def handle_event("sort", %{"att" => att}, socket) do
    {:noreply, redirect_with_attrs(socket, sort_by: att)}
  end
  def handle_event("sort", %{"att-g" => attg}, socket) do
    {:noreply, redirect_with_attrs(socket, sort_by: attg)}
  end
  def handle_event("sort", %{"avg" => avg}, socket) do
    {:noreply, redirect_with_attrs(socket, sort_by: avg)}
  end
  def handle_event("sort", %{"yds-g" => ydsg}, socket) do
    {:noreply, redirect_with_attrs(socket, sort_by: ydsg)}
  end
  def handle_event("sort", %{"yds" => yds}, socket) do
    {:noreply, redirect_with_attrs(socket, sort_by: yds)}
  end
  def handle_event("sort", %{"td" => td}, socket) do
    {:noreply, redirect_with_attrs(socket, sort_by: td)}
  end
  def handle_event("sort", %{"lng" => lng}, socket) do
    {:noreply, redirect_with_attrs(socket, sort_by: lng)}
  end
  def handle_event("sort", %{"1st" => first}, socket) do
    {:noreply, redirect_with_attrs(socket, sort_by: first)}
  end
  def handle_event("sort", %{"1st%" => firstpercent}, socket) do
    {:noreply, redirect_with_attrs(socket, sort_by: firstpercent)}
  end
  def handle_event("sort", %{"20+" => twenty}, socket) do
    {:noreply, redirect_with_attrs(socket, sort_by: twenty)}
  end
  def handle_event("sort", %{"40+" => forty}, socket) do
    {:noreply, redirect_with_attrs(socket, sort_by: forty)}
  end
  def handle_event("sort", %{"fum" => fum}, socket) do
    {:noreply, redirect_with_attrs(socket, sort_by: fum)}
  end

  def handle_event("goto-page", %{"page" => page}, socket) do
    {:noreply, redirect_with_attrs(socket, page: String.to_integer(page))}
  end

  def handle_event("change-page-size", %{"page_size" => page_size}, socket) do
    {:noreply, redirect_with_attrs(socket, page_size: String.to_integer(page_size), page: 1)}
  end



  defp redirect_with_attrs(socket, attrs) do
    query = attrs[:query] || socket.assigns[:query]
    sort_by = attrs[:sort_by] || socket.assigns[:sort_by]
    sort_order = attrs[:sort_order] || socket.assigns[:sort_order]
    page = attrs[:page] || socket.assigns[:page]
    page_size = attrs[:page_size] || socket.assigns[:page_size]

    live_redirect(socket, to: Routes.live_path(socket, NflRushingWeb.PlayerLive, query: query, sort_by: sort_by, sort_order: sort_order, page: page, page_size: page_size))
  end

  defp rows(%{data: data, query: query, sort_by: sort_by, sort_order: sort_order, page: page, page_size: page_size}) do
    data |> filter(query) |> sort(sort_by, sort_order) |> paginate(page, page_size)
  end

  defp filter(rows, query) do
    rows |> Enum.filter(&(String.match?(&1["Player"], ~r/#{query}/i)))
  end

  defp sort(rows, sort_by, :asc), do: rows |> Enum.sort(&(&1[sort_by] > &2[sort_by]))
  defp sort(rows, sort_by, :desc), do: rows |> Enum.sort(&(&1[sort_by] <= &2[sort_by]))

  defp paginate(rows, page, page_size), do: rows |> Enum.slice((page - 1) * page_size, page_size)

  defp number_of_pages(%{data: data, query: query, page_size: page_size}) do
    number_of_rows = data |> filter(query) |> length
    (number_of_rows / page_size) + 1 |> trunc
  end

  defp sort_order_icon(column, sort_by, :asc) when column == sort_by, do: "▲"
  defp sort_order_icon(column, sort_by, :desc) when column == sort_by, do: "▼"
  defp sort_order_icon(_, _, _), do: ""
end
