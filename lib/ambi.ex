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

  # This method looks for a single row in the reading_metadata table and
  # updates it with the values past in from the sensor client
  def set_reading_metadata(attrs \\ %{}) do
    Logger.debug "reading_metadata: #{inspect(attrs)}"
    id = 1;
    result =
      case Repo.get(Ambi.ReadingMetadata, id) do
        nil  -> %Ambi.ReadingMetadata{id: id} # ReadingMetadata instance not found, we build one
        reading_metadata -> reading_metadata  # ReadingMetadata instance exists, let's use it
      end
      |> Ambi.ReadingMetadata.changeset(attrs)
      |> Repo.insert_or_update
    Logger.debug "result: #{inspect(result)}"

    #case result do
    #  {:ok, _struct}       -> Logger.debug "** Set reading metadata successfully"
    #  {:error, _changeset} -> Logger.error "** Failed to update the ReadingMetadata table"
    #end
  end

  def get_reading_metadata() do
    # Get the first entry, id: 1
    Repo.get(Ambi.ReadingMetadata, 1)
  end

  def get_timestamp_resolution_seconds() do
    md = get_reading_metadata()
    md.timestamp_resolution_seconds
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

    query =
      from r in Ambi.Reading,
        order_by: [desc: :inserted_at],
        where: r.inserted_at >= ^one_day_ago

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
      limit: 25 # temporary

    Repo.all(query)
  end

  def get_avg_temperature_over_1hr(hour) do
    n_hours_ago = Timex.shift(Timex.now, hours: hour, minutes: 0)
    nm_hours_ago = Timex.shift(Timex.now, hours: hour+1, minutes: 0)

    query =
      from r in Ambi.Reading,
      order_by: [desc: :inserted_at],
      where: r.inserted_at >= ^n_hours_ago and r.inserted_at < ^nm_hours_ago,
      select: {r.temperature}

    Repo.aggregate(query, :avg, :temperature)
  end

  def get_avg_temperatures_over_24hrs() do
    # Iterate over the last 24 hours and get the average temperature over each
    # 1 hour segment
    Enum.map_every(-24..-1, 1, fn hour ->
      get_avg_temperature_over_1hr(hour)
    end)
  end

  def get_average_humidity() do
    Repo.aggregate(Ambi.Reading, :avg, :humidity)
  end

 # Gets the average humidity from the DB over the last 24 hour period
  def get_average_humidity_24hrs() do
    one_day_ago = Timex.shift(Timex.now, hours: -24, minutes: 0)
    query =
      from r in Ambi.Reading,
        order_by: [desc: :inserted_at],
        where: r.inserted_at >= ^one_day_ago

    Repo.aggregate(query, :avg, :humidity)
  end

  def get_max_humidity() do
    Repo.aggregate(Ambi.Reading, :max, :humidity)
  end

  def get_min_humidity() do
    Repo.aggregate(Ambi.Reading, :min, :humidity)
  end

  def get_humidities_over_24hrs() do
    twenty_four_hours_ago = Timex.shift(Timex.now, hours: -24, minutes: 0)

    query =
      from r in Ambi.Reading,
      order_by: [desc: :inserted_at],
      where: r.inserted_at >= ^twenty_four_hours_ago,
      select: {r.humidity}

    Repo.all(query)
  end

  def get_avg_humidity_over_1hr(hour) do
    n_hours_ago = Timex.shift(Timex.now, hours: hour, minutes: 0)
    nm_hours_ago = Timex.shift(Timex.now, hours: hour+1, minutes: 0)

    query =
      from r in Ambi.Reading,
      order_by: [desc: :inserted_at],
      where: r.inserted_at >= ^n_hours_ago and r.inserted_at < ^nm_hours_ago,
      select: {r.humidity}

    Repo.aggregate(query, :avg, :humidity)
  end

  def get_avg_humidities_over_24hrs() do
    # Iterate over the last 24 hours and get the average humidity over each
    # 1 hour segment
    Enum.map_every(-24..-1, 1, fn hour ->
      get_avg_humidity_over_1hr(hour)
    end)
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
