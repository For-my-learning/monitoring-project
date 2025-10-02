defmodule Monitoring.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      MonitoringWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:monitoring, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Monitoring.PubSub},
      # Start a worker by calling: Monitoring.Worker.start_link(arg)
      # {Monitoring.Worker, arg},
      # Start to serve requests, typically the last entry
    MonitoringWeb.Endpoint,

    Monitoring.MetricsPoller
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Monitoring.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MonitoringWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
