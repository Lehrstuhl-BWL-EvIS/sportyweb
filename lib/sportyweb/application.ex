defmodule Sportyweb.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      SportywebWeb.Telemetry,
      # Start the Ecto repository
      Sportyweb.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Sportyweb.PubSub},
      # Start Finch
      {Finch, name: Sportyweb.Finch},
      # Start the Endpoint (http/https)
      SportywebWeb.Endpoint
      # Start a worker by calling: Sportyweb.Worker.start_link(arg)
      # {Sportyweb.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Sportyweb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SportywebWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
