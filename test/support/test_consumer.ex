defmodule ExdaTest.TestConsumer do
  use Exda.Consumer, [:message_produced]

  @moduledoc """
    Test consumer that recieves either keyword list or map as an event.
  """
  @impl true
  def consume_message_produced(event_data) when is_map(event_data) do
    send(Map.get(event_data, :pid), Map.put(event_data, :from, self()))

    :ok
  end

  def consume_message_produced(event_data) when is_list(event_data) do
    send(Map.get(event_data, :pid), Keyword.put(event_data, :from, self()))

    :ok
  end
end
