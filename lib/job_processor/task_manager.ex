defmodule JobProcessor.TaskManager do
  def process_tasks(tasks) do
    with {:ok, sorted_tasks} <- sort_tasks(tasks) do
      bash_script = generate_bash_script(sorted_tasks)
      save_script_to_file(bash_script)
      {:ok, sorted_tasks, bash_script}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  # Topological sort for task dependencies
  defp sort_tasks(tasks) do
    task_map = Map.new(tasks, fn task -> {task["name"], task} end)

    adjacency_map =
      Enum.reduce(tasks, %{}, fn task, acc ->
        Map.put(acc, task["name"], task["requires"] || [])
      end)

    case TopologicalSort.sort(adjacency_map) do
      {:ok, ordered_names} ->
        sorted_tasks = Enum.map(ordered_names, &task_map[&1])
        {:ok, sorted_tasks}

      {:error, _cycle} ->
        {:error, "Circular dependency detected"}
    end
  end

  defp generate_bash_script(tasks) do
    script_body =
      tasks
      |> Enum.map(& &1["command"])
      |> Enum.join("\n")

    "#!/usr/bin/env bash\n" <> script_body <> "\n"
  end

  defp save_script_to_file(script_content) do
    # Save the generated script content to a file (e.g., script.sh)
    File.write!("script.sh", script_content)
    File.chmod!("script.sh", 0o755)
  end
end
