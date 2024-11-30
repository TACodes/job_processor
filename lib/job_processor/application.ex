defmodule JobProcessor.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      JobProcessorWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:job_processor, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: JobProcessor.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: JobProcessor.Finch},
      # Start a worker by calling: JobProcessor.Worker.start_link(arg)
      # {JobProcessor.Worker, arg},
      # Start to serve requests, typically the last entry
      JobProcessorWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: JobProcessor.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    JobProcessorWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
