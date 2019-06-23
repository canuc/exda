defmodule PhoenixExdaSampleWeb.PageController do
  use PhoenixExdaSampleWeb, :controller
  use Exda.Producer, [:user_index_requested]

  def index(conn, params) do
    notify_user_index_requested(params)

    render(conn, "index.html")
  end
end
