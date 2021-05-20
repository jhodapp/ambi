defmodule Ambi.ReadingMetadata do
  use Ecto.Schema
  import Ecto.Changeset

  schema "reading_metadata" do
    field :timestamp_resolution_seconds, :integer
  end

  @spec changeset(
          {map, map}
          | %{
              :__struct__ => atom | %{:__changeset__ => map, optional(any) => any},
              optional(atom) => any
            },
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: Ecto.Changeset.t()
  @doc false
  def changeset(reading, attrs) do
    reading
    |> cast(attrs, [:timestamp_resolution_seconds])
    |> validate_required([:timestamp_resolution_seconds])
  end
end
