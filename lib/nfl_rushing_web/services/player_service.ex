defmodule NflRushing.PlayerService do
  def get_stats() do
    Path.expand("rushing.json")
    |> File.read!()
    |> Jason.decode!
  end

  def filter(rows, query) do
    rows
    |> Enum.filter(&(String.match?(&1["Player"], ~r/#{query}/i)))
  end

  def sort(rows, sort_by, :asc) when sort_by == "Lng" do
    rows
    |> Enum.map(&format_lng(&1))
    |> Enum.sort(&(&1[sort_by] > &2[sort_by]))
  end
  def sort(rows, sort_by, :desc) when sort_by == "Lng" do
    rows
    |> Enum.map(&format_lng(&1))
    |> Enum.sort(&(&1[sort_by] <= &2[sort_by]))
  end
  def sort(rows, sort_by, :asc), do: rows |> Enum.sort(&(&1[sort_by] > &2[sort_by]))
  def sort(rows, sort_by, :desc), do: rows |> Enum.sort(&(&1[sort_by] <= &2[sort_by]))

  def paginate(rows, page, page_size), do: rows |> Enum.slice((page - 1) * page_size, page_size)

  def number_of_pages(%{data: data, query: query, page_size: page_size}) do
    number_of_rows = data |> filter(query) |> length
    (number_of_rows / page_size) + 1 |> trunc
  end

  defp format_lng(%{"Lng" => value} = row) do
    string_value = ensure_string(value)
    length = String.length(string_value)
    replaced_value =
      case String.ends_with?(string_value, "T") do
        true -> String.slice(value, 0, length-1)
        _ -> string_value
      end

    Map.replace(row, "Lng", String.to_integer(replaced_value))
  end

  defp ensure_string(value) when is_integer(value), do: Integer.to_string(value)
  defp ensure_string(value) when is_binary(value), do: value

  def sort_order_icon(column, sort_by, :asc) when column == sort_by, do: "▲"
  def sort_order_icon(column, sort_by, :desc) when column == sort_by, do: "▼"
  def sort_order_icon(_, _, _), do: ""
end
