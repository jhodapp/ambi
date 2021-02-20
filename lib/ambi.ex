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

  def reset_readings() do
    Repo.reset_readings(Ambi.Reading)
  end

  def get_reading() do
    %{temperature: get_temp(),
      humidity: get_humidity(),
      pressure: get_pressure(),
      dust_concentration: get_dust_concentration(),
      air_purity: get_air_purity(),
      average_temp: get_average_temp(),
      average_temp_24hrs: get_average_temp_24hrs(),
      max_temp: get_max_temp(),
      min_temp: get_min_temp(),
      average_humidity: get_average_humidity(),
      average_humidity_24hrs: get_average_humidity_24hrs(),
      max_humidity: get_max_humidity(),
      min_humidity: get_min_humidity(),
      readings_count: get_readings_count(),
      last_inserted_at: get_last_inserted_at(),
      first_inserted_at: get_first_inserted_at()
    }
  end

  def get_temp() do
    get_last_row().temperature
  end

  def get_humidity() do
    query =
      from Ambi.Reading,
        order_by: [desc: :humidity],
        limit: 2
    humidities = Repo.all(query)
    Logger.debug "humidities: #{inspect(humidities)}"
    Logger.debug "humidity count: #{inspect(Repo.aggregate(query, :count, :id))}"
    Repo.aggregate(query, :avg, :humidity)
    get_last_row().humidity
  end

  def get_pressure() do
    get_last_row().pressure
  end

  def get_dust_concentration() do
    get_last_row().dust_concentration
  end

  def get_air_purity() do
    get_last_row().air_purity
  end

  # Gets the average temperature from the DB over all sensor readings
  def get_average_temp() do
    Repo.aggregate(Ambi.Reading, :avg, :temperature)
  end

  # Gets the average temperature from the DB over the last 24 hour period
  def get_average_temp_24hrs() do
    one_day_ago = Timex.shift(Timex.now, hours: -24, minutes: 0)
    Logger.debug "24 hrs ago: #{inspect(one_day_ago)}"
    Logger.debug "now: #{inspect(Timex.now)}"
    query =
      from r in Ambi.Reading,
        order_by: [desc: :inserted_at],
        where: r.inserted_at >= ^one_day_ago
    Logger.debug "query: #{inspect(query)}"

    Logger.debug "total count: #{inspect(Repo.aggregate(Ambi.Reading, :count, :id))}"
    Logger.debug "24 hour count: #{inspect(Repo.aggregate(query, :count, :id))}"
    Repo.aggregate(query, :avg, :temperature)
  end

  def get_max_temp() do
    Repo.aggregate(Ambi.Reading, :max, :temperature)
  end

  def get_min_temp() do
    Repo.aggregate(Ambi.Reading, :min, :temperature)
  end

  def get_temperatures_over_120s() do
    two_mins_ago = Timex.shift(Timex.now, hours: 0, minutes: -4)

    query =
      from r in Ambi.Reading,
      order_by: [desc: :inserted_at],
      where: r.inserted_at >= ^two_mins_ago,
      select: {r.temperature},
      limit: 24 # temporary

    results = Repo.all(query)
    Logger.debug "results: #{inspect(results)}"
    results
  end

  def get_average_humidity() do
    Repo.aggregate(Ambi.Reading, :avg, :humidity)
  end

 # Gets the average humidity from the DB over the last 24 hour period
  def get_average_humidity_24hrs() do
    one_day_ago = Timex.shift(Timex.now, hours: -24, minutes: 0)
    Logger.debug "24 hrs ago: #{inspect(one_day_ago)}"
    Logger.debug "now: #{inspect(Timex.now)}"
    query =
      from r in Ambi.Reading,
        order_by: [desc: :inserted_at],
        where: r.inserted_at >= ^one_day_ago
    Logger.debug "query: #{inspect(query)}"

    Logger.debug "total count: #{inspect(Repo.aggregate(Ambi.Reading, :count, :id))}"
    Logger.debug "24 hour count: #{inspect(Repo.aggregate(query, :count, :id))}"
    Repo.aggregate(query, :avg, :humidity)
  end

  def get_max_humidity() do
    Repo.aggregate(Ambi.Reading, :max, :humidity)
  end

  def get_min_humidity() do
    Repo.aggregate(Ambi.Reading, :min, :humidity)
  end

  def get_humidities_over_120s() do
    two_mins_ago = Timex.shift(Timex.now, hours: 0, minutes: -2)

    query =
      from r in Ambi.Reading,
      order_by: [desc: :inserted_at],
      where: r.inserted_at >= ^two_mins_ago,
      select: {r.humidity},
      limit: 24 # temporary

    results = Repo.all(query)
    Logger.debug "results: #{inspect(results)}"
    results
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
