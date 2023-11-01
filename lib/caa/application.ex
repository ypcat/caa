defmodule Caa.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      CaaWeb.Telemetry,
      # Start the Ecto repository
      Caa.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Caa.PubSub},
      # Start Finch
      {Finch, name: Caa.Finch},
      # Start the Endpoint (http/https)
      CaaWeb.Endpoint
      # Start a worker by calling: Caa.Worker.start_link(arg)
      # {Caa.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Caa.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CaaWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
