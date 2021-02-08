defmodule AmbiWeb.ReadingLive do
  use AmbiWeb, :live_view

  require Logger

  def mount(_params, _session, socket) do
    #Presence.track(self(), @presence_topic, socket.id, %{})
    #Ambi.Endpoint.subscribe(@presence_topic)
    Logger.debug "mount() called, subscribing to :added event"
    Ambi.subscribe()

    {:ok, assign(socket, %{reading: Ambi.get_reading()})}
  end

  #def handle_info({Ambi.PubSub, :added, _}, socket) do
  def handle_info(:added, socket) do
    Logger.debug "Received :added event message"
    {:noreply, assign(socket, %{reading: Ambi.get_reading()})}
  end

  def render(assigns) do
    #Ambi.PageView.render("reading.html", assigns)
    ~L"""
    <section class="phx-hero">
      <h1>Live Readings</h1>
      <p>
        Current temp: <%= @reading.temperature |> Decimal.from_float() |> Decimal.round(1) %> C <br/>
        Current humidity: <%= @reading.humidity  |> Decimal.from_float() |> Decimal.round(1) %>% <br/>
        Current pressure: <%= @reading.pressure %> mb <br/>
        Current dust concentration: <%= @reading.dust_concentration |> Decimal.from_float() |> Decimal.round(0) %> pieces/liter <br/>
        Current air purity: <%= @reading.air_purity %> <br/>
        <hr class="dotted"/>
        Average temp: <%= @reading.average_temp |> Decimal.from_float() |> Decimal.round(1) %> C <br/>
        Max temp: <%= @reading.max_temp |> Decimal.from_float() |> Decimal.round(1) %> C <br/>
        Min temp: <%= @reading.min_temp |> Decimal.from_float() |> Decimal.round(1) %> C <br/>
        <hr class="dotted"/>
        Average humidity: <%= @reading.average_humidity |> Decimal.from_float() |> Decimal.round(1) %>%  <br/>
        Max humidity: <%= @reading.max_humidity |> Decimal.from_float() |> Decimal.round(1) %>% <br/>
        Min humidity: <%= @reading.min_humidity |> Decimal.from_float() |> Decimal.round(1) %>% <br/>
        <hr class="dotted"/>
        <%= @reading.readings_count %> readings <br/>
        First: <%= @reading.first_inserted_at %> <br/>
        Last: <%= @reading.last_inserted_at %>
      </p>
    </section
    """
  end
end
