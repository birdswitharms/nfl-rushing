defmodule NflRushing.PlayerService do
  def get_stats() do
    Path.expand("rushing.json")
    |> File.read!()
    |> Jason.decode!
  end
end
