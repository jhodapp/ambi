defmodule Ambi.Timer do
  use GenServer
  require Logger

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end
  ## SERVER ##

  def init(_state) do
    Logger.warn "Ambi timer server started"
    broadcast()
    schedule_timer(10_000) # 1 sec timer
    {:ok, 0}
  end

  def handle_info(:update, _time) do
    broadcast()
    schedule_timer(5_000)
    {:noreply, 0}
  end

  defp schedule_timer(interval) do
    Process.send_after(self(), :update, interval)
  end

  defp broadcast() do
    Ambi.broadcast_change(:reading_refresh)
  end
end
