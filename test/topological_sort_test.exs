defmodule TopologicalSortTest do
  use ExUnit.Case

  test "topological sort test with adjacency map" do
    adjacency_map = %{
      "task1" => ["task2", "task3"],
      "task2" => ["task4"],
      "task3" => [],
      "task4" => []
    }

    adjacency_map_error = %{
      "task1" => ["task2", "task3"],
      "task2" => ["task4"],
      "task3" => [],
      "task4" => ["task1"]
    }

    assert {:ok, ["task4", "task2", "task3", "task1"]} == TopologicalSort.sort(adjacency_map)

    assert {:error, "Cycle detected involving task task1"} ==
             TopologicalSort.sort(adjacency_map_error)
  end
end
