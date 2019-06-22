defmodule Exda.EventBuses.AsyncCastGenServer do
  @spec handle_event(event_name :: atom(), consumer :: module(), event_data :: any()) ::
          Exda.Producer.bus_callback()
  def handle_event(event_name, consumer, event_data) do
    {:ok, pid} =
      case Process.whereis(consumer) do
        nil -> GenServer.start(consumer, [], name: consumer)
        pid -> {:ok, pid}
      end

    with :ok <- GenServer.cast(pid, {:consume_event, event_name, event_data}) do
      {:ok, pid}
    else
      _ -> {:error, %Exda.Exception.CastError{message: "Error processing event: #{event_name}."}}
    end
  end
end
