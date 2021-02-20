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

  #defp get_points, do: 1..7 |> Enum.map(fn _ -> :rand.uniform(100) end)

  defp get_temperatures do
    list = Ambi.get_temperatures_over_120s()
    Enum.flat_map(list, fn ({value}) -> [Float.round(value, 1)] end)
  end

  defp get_humidities do
    list = Ambi.get_humidities_over_120s()
    Enum.flat_map(list, fn ({value}) -> [Float.round(value, 1)] end)
  end
end
