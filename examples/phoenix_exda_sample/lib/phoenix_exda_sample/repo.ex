defmodule PhoenixExdaSample.Repo do
  use Ecto.Repo,
    otp_app: :phoenix_exda_sample,
    adapter: Ecto.Adapters.Postgres
end
