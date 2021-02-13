defmodule Ambi do
  @moduledoc """
  Ambi keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  import Ecto.Query, warn: false
  use Timex
  require Logger
  alias Ambi.Repo
  alias Phoenix.PubSub

  def add_reading(attrs \\ %{}) do
    %Ambi.Reading{}
    |> Ambi.Reading.changeset(attrs)
    |> Repo.insert()
    #broadcast_change(:added)
    #Logger.debug "Added new reading and called broadcast_change()"
    Logger.debug "Added new reading to the DB"
  end

  def get_reading() do
    %{temperature: get_last_temp(),
      humidity: get_last_humidity(),
      pressure: get_last_pressure(),
      dust_concentration: get_last_dust_concentration(),
      air_purity: get_last_air_purity(),
      average_temp: get_average_temp(),
      max_temp: get_max_temp(),
      min_temp: get_min_temp(),
      average_humidity: get_average_humidity(),
      max_humidity: get_max_humidity(),
      min_humidity: get_min_humidity(),
      readings_count: get_readings_count(),
      last_inserted_at: get_last_inserted_at(),
      first_inserted_at: get_first_inserted_at()
    }
  end

  def get_last_temp() do
    get_last_row().temperature
  end

  def get_last_humidity() do
    get_last_row().humidity
  end

  def get_last_pressure() do
    get_last_row().pressure
  end

  def get_last_dust_concentration() do
    get_last_row().dust_concentration
  end

  def get_last_air_purity() do
    get_last_row().air_purity
  end

  def get_average_temp() do
    Repo.aggregate(Ambi.Reading, :avg, :temperature)
  end

  def get_max_temp() do
    Repo.aggregate(Ambi.Reading, :max, :temperature)
  end

  def get_min_temp() do
    Repo.aggregate(Ambi.Reading, :min, :temperature)
  end

  def get_average_humidity() do
    Repo.aggregate(Ambi.Reading, :avg, :humidity)
  end

  def get_max_humidity() do
    Repo.aggregate(Ambi.Reading, :max, :humidity)
  end

  def get_min_humidity() do
    Repo.aggregate(Ambi.Reading, :min, :humidity)
  end

  def get_last_inserted_at() do
    Timezone.convert(get_last_row().inserted_at, "America/Chicago")
  end

  def get_first_inserted_at() do
    Timezone.convert(get_first_row().inserted_at, "America/Chicago")
  end

  defp get_last_row() do
    Repo.one(from s in Ambi.Reading, order_by: [desc: s.id], limit: 1)
  end

  defp get_first_row() do
    Repo.one(from s in Ambi.Reading, order_by: [asc: s.id], limit: 1)
  end

  defp get_readings_count() do
    Repo.aggregate(Ambi.Reading, :count, :id)
  end

  @topic inspect(__MODULE__)
  def subscribe() do
    PubSub.subscribe(Ambi.PubSub, @topic)
    Logger.debug """
    Subscribe details:
    topic: #{inspect(@topic)}
    """
  end

  def broadcast_change(event) do
    PubSub.broadcast(Ambi.PubSub, @topic, event)
    Logger.debug """
    Broadcast details:
    topic: #{inspect(@topic)}
    module: #{inspect(__MODULE__)}
    event: #{inspect(event)}
    """
    :ok
  end
end
