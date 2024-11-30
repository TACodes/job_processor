defmodule JobProcessorWeb.JobController do
  use JobProcessorWeb, :controller
  alias JobProcessor.TaskManager

  def process(conn, %{"tasks" => tasks}) do
    case TaskManager.process_tasks(tasks) do
      {:ok, ordered_tasks, bash_script} ->
        json(conn, %{
          tasks: ordered_tasks,
          script: bash_script
        })

      {:error, reason} ->
        conn
        |> put_status(:unprocessable_job)
        |> json(%{error: reason})
    end
  end
end
