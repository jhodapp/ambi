defmodule Ambi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Ambi.Repo,
      # Start the Telemetry supervisor
      AmbiWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Ambi.PubSub},
      # Start the Endpoint (http/https)
      AmbiWeb.Endpoint
      # Start a worker by calling: Ambi.Worker.start_link(arg)
      # {Ambi.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Ambi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    AmbiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
