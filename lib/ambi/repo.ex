defmodule Ambi.Repo do
  use Ecto.Repo,
    otp_app: :ambi,
    adapter: Ecto.Adapters.Postgres

  def reset_readings(schema) do
    table_name = schema.__schema__(:source)
    query("TRUNCATE #{table_name}", [])
    :ok
  end
end
