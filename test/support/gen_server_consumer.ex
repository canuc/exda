defmodule ExdaTest.GenServerConsumer do
  use Exda.GenServerConsumer, [:message_produced]

  @impl true
  def consume_message_produced(event_data) do
    send(Map.get(event_data, :pid), event_data)

    :random_value
  end
end
