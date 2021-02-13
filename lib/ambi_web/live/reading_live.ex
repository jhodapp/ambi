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
    {:noreply, assign(socket, %{reading: Ambi.get_reading()})}
  end
end
