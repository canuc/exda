defmodule Exda.EventBuses.Synchronous do
  @moduledoc """

  A Synchronous message bus that will call the consumer directly on the 
  same caller process.

  This is the default bus that is used if there is none specified.

  """
  @spec handle_event(event_name :: String.t(), consumer :: module(), event_data :: any()) ::
          Exda.Producer.bus_callback()
  def handle_event(event_name, consumer, event_data) do
    apply(consumer, :"consume_#{event_name}", [event_data])
  end
end
