defmodule AmbiWeb.ReadingLive do
  use AmbiWeb, :live_view

  require Logger

  def mount(_params, _session, socket) do
    Logger.debug "ReadingLive.mount() called, subscribing PubSub topic"
    Ambi.subscribe()

    socket = assign(socket, %{reading: Ambi.get_reading()})
    {:ok, socket}
  end

  def handle_info(:added, socket) do
    Logger.debug "Received :added event message"
    {:noreply, assign(socket, %{reading: Ambi.get_reading()})}
  end

  def handle_info(:reading_refresh, socket) do
    Logger.debug "Received :refresh_reading event message"
    {:noreply, assign(socket, %{reading: Ambi.get_reading()})
     |> push_event("humidity_points", %{humidity_points: get_humidities()})
     |> push_event("temperature_points", %{temperature_points: get_temperatures()})
    }
  end

  defp get_temperatures do
    Ambi.get_avg_temperatures_over_24hrs()
  end

  defp get_humidities do
    #timestamp_resolution_seconds = Ambi.get_timestamp_resolution_seconds()
    #Logger.debug "****** #{inspect(timestamp_resolution_seconds)}"
    #label_every_nth_point = div(86000, timestamp_resolution_seconds)

    Ambi.get_avg_humidities_over_24hrs()
  end
end
