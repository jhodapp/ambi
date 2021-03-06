defmodule AmbiWeb.Router do
  use AmbiWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {AmbiWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", AmbiWeb do
    pipe_through :browser

    live "/", ReadingLive
    live "/about", AboutController
  end

  scope "/api", AmbiWeb do
    pipe_through :api

    # API endpoint to add a new sensor reading to the database
    post "/readings/add", ApiController, :add_reading

    # API endpoint to set general reading metadata (e.g. timestamp resolution in secs)
    post "/reading_metadata/set", ApiController, :set_metadata

    # API endpoint that clear out the DB of all readings
    get "/readings/reset", ApiController, :reset
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: AmbiWeb.Telemetry
    end
  end
end
