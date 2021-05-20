defmodule Ambi.Repo.Migrations.CreateReadingMetadata do
  use Ecto.Migration

  def change do
    create table(:reading_metadata) do
      add :timestamp_resolution_seconds, :integer
    end
  end
end
