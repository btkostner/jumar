defmodule Jumar.Repo.Reconnector do
  @moduledoc """
  Restarts the `Jumar.Repo` database pool every 30 minutes to ensure we are
  connected to the closest node. When a database node shuts down, ecto will
  automatically reconnect to a node still standing. Once the node comes back
  online, ecto will _not_ automatically reconnect. To deal with this
  shortcoming, this module was created.
  """

  use GenServer

  require Logger

  alias Jumar.Repo

  @disconnect_interval :timer.minutes(30)
  @disconnect_grace :timer.minutes(5)

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    {:ok, nil, {:continue, :set_timeout}}
  end

  @impl true
  def handle_continue(:set_timeout, nil) do
    schedule_reconnect()
    {:noreply, nil}
  end

  @impl true
  def handle_info(:reconnect, nil) do
    Logger.debug("Reconnecting to database")

    %{pid: pid, opts: opts} = Ecto.Adapter.lookup_meta(Repo.get_dynamic_repo())
    DBConnection.disconnect_all(pid, @disconnect_grace, opts)

    schedule_reconnect()
    {:noreply, nil}
  end

  defp schedule_reconnect do
    Process.send_after(self(), :reconnect, @disconnect_interval)
  end
end
