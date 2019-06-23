defmodule PhoenixExdaSampleWeb.Router do
  use PhoenixExdaSampleWeb, :router


  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug PhoeonixExdaSample.Plug.HttpRequestPlug
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug PhoeonixExdaSample.Plug.HttpRequestPlug
  end

  scope "/", PhoenixExdaSampleWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", PhoenixExdaSampleWeb do
  #   pipe_through :api
  # end
end
