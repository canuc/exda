defmodule ExdaTest do
  use ExUnit.Case
  doctest Exda

  defp put_consumer_in_exda_env(consumer, bus \\ Exda.EventBuses.Synchronous)

  defp put_consumer_in_exda_env(consumer, Exda.EventBuses.Synchronous) do
    Application.put_env(:exda, :consumers, message_produced: [consumer])
  end

  defp put_consumer_in_exda_env(consumer, bus) do
    Application.put_env(:exda, :consumers, message_produced: [{consumer, bus}])
  end

  describe "eda producer" do
    setup do
      Application.put_env(:exda, :bus, Exda.EventBuses.Synchronous)
    end

    test "producer should be able to be configured with a consumer" do
      put_consumer_in_exda_env(ExdaTest.TestConsumer)
      event_property = :crypto.strong_rand_bytes(1)

      ExdaTest.Producer.send_notify_message_produced(%{
        event_property: event_property,
        pid: self()
      })

      assert_receive %{event_property: received_info}
      assert received_info == event_property
    end

    test "producer should handle a bad return value" do
      put_consumer_in_exda_env(ExdaTest.BadConsumer)
      event_property = :crypto.strong_rand_bytes(1)

      ExdaTest.Producer.send_notify_message_produced(%{
        event_property: event_property,
        pid: self()
      })

      assert_receive %{event_property: received_info}
      assert received_info == event_property
    end

    test "producer should handle GenServerConsumer with a gen_server bus" do
      put_consumer_in_exda_env(ExdaTest.GenServerConsumer, Exda.EventBuses.AsyncCastGenServer)
      event_property = :crypto.strong_rand_bytes(1)

      ExdaTest.Producer.send_notify_message_produced(%{
        event_property: event_property,
        pid: self()
      })

      assert_receive %{event_property: received_info}
      assert received_info == event_property
    end

    test "producer should handle two consumers with same bus" do
      Application.put_env(:exda, :consumers,
        message_produced: [
          {ExdaTest.TestConsumer, Exda.EventBuses.Synchronous},
          ExdaTest.TestConsumer
        ]
      )

      event_property = :crypto.strong_rand_bytes(1)

      producer_response =
        ExdaTest.Producer.send_notify_message_produced(%{
          event_property: event_property,
          pid: self()
        })

      assert_receive %{event_property: received_event_property}
      assert received_event_property == event_property
      assert_receive %{event_property: received_event_property}
      assert received_event_property == event_property

      assert {:ok,
              [{ExdaTest.TestConsumer, {:ok, :empty}}, {ExdaTest.TestConsumer, {:ok, :empty}}]} =
               producer_response
    end

    test "producer should handle two consumers with different buses" do
      Application.put_env(:exda, :consumers,
        message_produced: [
          {ExdaTest.TestConsumer, Exda.EventBuses.AsyncTask},
          ExdaTest.TestConsumer
        ]
      )

      event_property = :crypto.strong_rand_bytes(1)

      producer_response =
        ExdaTest.Producer.send_notify_message_produced(%{
          event_property: event_property,
          pid: self()
        })

      assert_receive %{event_property: received_event_property}
      assert received_event_property == event_property
      assert_receive %{event_property: received_event_property}
      assert received_event_property == event_property

      assert {:ok, [{ExdaTest.TestConsumer, {:ok, pid}}, {ExdaTest.TestConsumer, {:ok, :empty}}]} =
               producer_response
    end
  end

  describe "default bus" do
    setup do
      Application.put_env(:exda, :bus, Exda.EventBuses.AsyncTask)
      put_consumer_in_exda_env(ExdaTest.TestConsumer)
      event_property = :crypto.strong_rand_bytes(1)

      {:ok, producer_response} =
        ExdaTest.Producer.send_notify_message_produced(%{
          event_property: event_property,
          pid: self()
        })

      {:ok, %{producer_response: {:ok, producer_response}}}
    end

    test "should allow overriding the default buffer", %{producer_response: producer_response} do
      assert_receive %{from: from}

      assert {:ok, [{ExdaTest.TestConsumer, {:ok, pid}}]} = producer_response
      assert from == pid
    end
  end
end
