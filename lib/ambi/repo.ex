defmodule Ambi.Repo do
  use Ecto.Repo,
    otp_app: :ambi,
    adapter: Ecto.Adapters.Postgres
end
