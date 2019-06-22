defmodule Exda.EventBuses.AsyncTask do
  @spec handle_event(event_name :: atom(), consumer :: module(), event_data :: any()) ::
          Exda.Producer.bus_callback()
  def handle_event(event_name, consumer, event_data) do
    Task.start(consumer, :"consume_#{event_name}", [event_data])
  end
end
