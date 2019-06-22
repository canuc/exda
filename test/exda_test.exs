defmodule ExdaTest do
  use ExUnit.Case
  doctest Exda

  defmodule Producer do
    use Exda.Producer, [:message_produced]

    @impl true
    def send_notify_message_produced(message) do
      notify_message_produced(message)
    end
  end

  defmodule TestConsumer do
    use Exda.Consumer, [:message_produced]

    @impl true
    def consume_message_produced(event_data) do
      send(Map.get(event_data, :pid), event_data)

      :ok
    end
  end

  defmodule BadConsumer do
    use Exda.Consumer, [:message_produced]

    @impl true
    def consume_message_produced(event_data) do
      send(Map.get(event_data, :pid), event_data)

      :random_value
    end
  end

  defmodule GenServerConsumer do
    use Exda.GenServerConsumer, [:message_produced]

    @impl true
    def consume_message_produced(event_data) do
      send(Map.get(event_data, :pid), event_data)

      :random_value
    end
  end

  defp put_consumer_in_exda_env(consumer, bus \\ Exda.EventBuses.Synchronous)

  defp put_consumer_in_exda_env(consumer, Exda.EventBuses.Synchronous) do
    Application.put_env(:exda, :consumers, message_produced: [consumer])
  end

  defp put_consumer_in_exda_env(consumer, bus) do
    Application.put_env(:exda, :consumers, message_produced: [{consumer, bus}])
  end

  describe "eda producer" do
    test "producer should be able to be configured with a consumer" do
      put_consumer_in_exda_env(TestConsumer)
      event_property = :crypto.strong_rand_bytes(1)
      Producer.send_notify_message_produced(%{event_property: event_property, pid: self()})

      assert_receive %{event_property: received_info}
      assert received_info == event_property
    end

    test "producer should handle a bad return value" do
      put_consumer_in_exda_env(BadConsumer)
      event_property = :crypto.strong_rand_bytes(1)
      Producer.send_notify_message_produced(%{event_property: event_property, pid: self()})

      assert_receive %{event_property: received_info}
      assert received_info == event_property
    end

    test "producer should handle GenServerConsumer with a gen_server bus" do
      put_consumer_in_exda_env(GenServerConsumer, Exda.EventBuses.AsyncCastGenServer)
      event_property = :crypto.strong_rand_bytes(1)
      Producer.send_notify_message_produced(%{event_property: event_property, pid: self()})

      assert_receive %{event_property: received_info}
      assert received_info == event_property
    end

    test "producer should handle two consumers with same bus" do
      Application.put_env(:exda, :consumers,
        message_produced: [
          {TestConsumer, Exda.EventBuses.Synchronous},
          TestConsumer
        ]
      )

      event_property = :crypto.strong_rand_bytes(1)

      producer_response =
        Producer.send_notify_message_produced(%{event_property: event_property, pid: self()})

      assert_receive %{event_property: received_event_property}
      assert received_event_property == event_property
      assert_receive %{event_property: received_event_property}
      assert received_event_property == event_property

      assert {:ok, [{TestConsumer, {:ok, :empty}}, {TestConsumer, {:ok, :empty}}]} =
               producer_response
    end

    test "producer should handle two consumers with different buses" do
      Application.put_env(:exda, :consumers,
        message_produced: [
          {TestConsumer, Exda.EventBuses.AsyncTask},
          TestConsumer
        ]
      )

      event_property = :crypto.strong_rand_bytes(1)

      producer_response =
        Producer.send_notify_message_produced(%{event_property: event_property, pid: self()})

      assert_receive %{event_property: received_event_property}
      assert received_event_property == event_property
      assert_receive %{event_property: received_event_property}
      assert received_event_property == event_property

      assert {:ok, [{TestConsumer, {:ok, pid}}, {TestConsumer, {:ok, :empty}}]} =
               producer_response
    end
  end
end
