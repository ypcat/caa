defmodule Caa.Repo do
  use Ecto.Repo,
    otp_app: :caa,
    adapter: Ecto.Adapters.Postgres
end
