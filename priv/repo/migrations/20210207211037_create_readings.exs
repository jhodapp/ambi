defmodule Ambi.Repo.Migrations.CreateReadings do
  use Ecto.Migration

  def change do
    create table(:readings) do
      add :temperature, :float
      add :humidity, :float
      add :dust_concentration, :float
      add :pressure, :integer
      add :air_purity, :string

      timestamps()
    end

  end
end
