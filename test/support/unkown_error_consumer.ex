defmodule ExdaTest.UnkownErrorConsumer do
  use Exda.Consumer, [:message_produced]

  @impl true
  def consume_message_produced(event_data) do
    send(Map.get(event_data, :pid), event_data)

    :error
  end
end
