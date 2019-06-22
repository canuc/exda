defmodule Exda.EventBuses.Synchronous do
  @spec handle_event(event_name :: String.t(), consumer :: module(), event_data :: any()) ::
          Exda.Producer.bus_callback()
  def handle_event(event_name, consumer, event_data) do
    apply(consumer, :"consume_#{event_name}", [event_data])
  end
end
