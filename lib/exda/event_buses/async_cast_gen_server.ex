defmodule Exda.EventBuses.AsyncCastGenServer do
  @moduledoc """

  This will call a `GenServer` resulting in all message
  being processed in its own pid asynchronously.

  """

  @spec handle_event(event_name :: atom(), consumer :: module(), event_data :: any()) ::
          Exda.Producer.bus_callback()
  def handle_event(event_name, consumer, event_data) do
    {:ok, pid} =
      case Process.whereis(consumer) do
        nil -> GenServer.start(consumer, [], name: consumer)
        pid -> {:ok, pid}
      end

    :ok = GenServer.cast(pid, {:consume_event, event_name, event_data})

    {:ok, pid}
  end
end
