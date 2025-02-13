defmodule PhoenixDeploy.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PhoenixDeployWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:phoenix_deploy, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: PhoenixDeploy.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: PhoenixDeploy.Finch},
      # Start a worker by calling: PhoenixDeploy.Worker.start_link(arg)
      # {PhoenixDeploy.Worker, arg},
      # Start to serve requests, typically the last entry
      PhoenixDeployWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PhoenixDeploy.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PhoenixDeployWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
