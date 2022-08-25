defmodule Sportyweb.Repo do
  use Ecto.Repo,
    otp_app: :sportyweb,
    adapter: Ecto.Adapters.Postgres
end
