defmodule TopologicalSort do
  @moduledoc """
  A module to perform topological sorting on a directed acyclic graph (DAG)
  represented as an adjacency map.
  """

  @doc """
  Sorts the tasks in topological order based on their dependencies.

  ## Parameters
  - adjacency_map: A map where keys are tasks and values are lists of dependencies.

  ## Returns
  - `{:ok, sorted_tasks}` if the graph is a DAG.
  - `{:error, reason}` if a cycle is detected.

  ## Example
      iex> adjacency_map = %{
      ...>   "task1" => ["task2", "task3"],
      ...>   "task2" => ["task4"],
      ...>   "task3" => [],
      ...>   "task4" => []
      ...> }
      iex> TopologicalSort.sort(adjacency_map)
      {:ok, ["task4", "task2", "task3", "task1"]}
  """
  def sort(adjacency_map) do
    adjacency_map
    |> Enum.reduce_while({:ok, {[], %{}}}, fn {task, dependencies}, {:ok, {result, visited}} ->
      case visit(task, dependencies, adjacency_map, visited, result) do
        {:ok, {new_result, new_visited}} ->
          {:cont, {:ok, {new_result, new_visited}}}

        {:error, reason} ->
          {:halt, {:error, reason}}
      end
    end)
    |> handle_result()
  end

  defp visit(task, dependencies, adjacency_map, visited, result) do
    case Map.get(visited, task, :unvisited) do
      :visiting ->
        {:error, "Cycle detected involving task #{task}"}

      :visited ->
        {:ok, {result, visited}}

      :unvisited ->
        visited = Map.put(visited, task, :visiting)

        case resolve_dependencies(dependencies, adjacency_map, visited, result) do
          {:ok, {resolved_result, resolved_visited}} ->
            resolved_visited = Map.put(resolved_visited, task, :visited)
            {:ok, {[task | resolved_result], resolved_visited}}

          error ->
            error
        end
    end
  end

  defp resolve_dependencies([], _adjacency_map, visited, result), do: {:ok, {result, visited}}

  defp resolve_dependencies([dep | rest], adjacency_map, visited, result) do
    dependencies = Map.get(adjacency_map, dep, [])

    case visit(dep, dependencies, adjacency_map, visited, result) do
      {:ok, {new_result, new_visited}} ->
        resolve_dependencies(rest, adjacency_map, new_visited, new_result)

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp handle_result({:ok, {sorted_tasks, _visited}}), do: {:ok, Enum.reverse(sorted_tasks)}
  defp handle_result({:error, reason}), do: {:error, reason}
end
