defmodule Exda.EventBuses.AsyncTask do
  @moduledoc """

  This will use `Task.start/3` and call each specified consumer as
  a new task with its own pid.

  """
  @spec handle_event(event_name :: atom(), consumer :: module(), event_data :: any()) ::
          Exda.Producer.bus_callback()
  def handle_event(event_name, consumer, event_data) do
    Task.start(consumer, :"consume_#{event_name}", [event_data])
  end
end
