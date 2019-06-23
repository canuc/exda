defmodule ExdaTest.ConsumerTest do
  use ExUnit.Case

  describe "eda consumer" do
    test "stops when halt gets returned by sync consumer" do
      Application.put_env(:exda, :consumers,
        message_produced: [
          {ExdaTest.TestConsumer, Exda.EventBuses.AsyncTask},
          ExdaTest.HaltingConsumer,
          {ExdaTest.TestConsumer, Exda.EventBuses.AsyncTask}
        ]
      )

      event_property = :crypto.strong_rand_bytes(1)

      producer_response =
        ExdaTest.Producer.send_notify_message_produced(%{
          event_property: event_property,
          pid: self()
        })

      assert {:ok,
              [
                {ExdaTest.TestConsumer, {:ok, pid}},
                {ExdaTest.HaltingConsumer, {:error, halting_exception}}
              ]} = producer_response

      assert %Exda.Exception.UnkownConsumerHalt{message: halt_message} = halting_exception
      assert halt_message =~ "halt by consumer"
      assert halt_message =~ "Elixir.ExdaTest.HaltingConsumer"
    end

    test "stops emission of events after a :halt is recieved by synchronous consumer" do
      Application.put_env(:exda, :consumers,
        message_produced: [
          {ExdaTest.TestConsumer, Exda.EventBuses.AsyncTask},
          ExdaTest.HaltingConsumer,
          {ExdaTest.TestConsumer, Exda.EventBuses.AsyncTask}
        ]
      )

      event_property = :crypto.strong_rand_bytes(1)

      ExdaTest.Producer.send_notify_message_produced(%{
        event_property: event_property,
        pid: self()
      })

      assert_receive %{event_property: received_event_property}
      assert received_event_property == event_property
      assert_receive %{event_property: received_event_property}
      assert received_event_property == event_property
    end

    test "exda will send to all consumers in the case of a consumer error" do
      Application.put_env(:exda, :consumers,
        message_produced: [
          ExdaTest.ErrorConsumer,
          {ExdaTest.TestConsumer, Exda.EventBuses.AsyncTask}
        ]
      )

      event_property = :crypto.strong_rand_bytes(1)

      ExdaTest.Producer.send_notify_message_produced(%{
        event_property: event_property,
        pid: self()
      })

      assert_receive %{event_property: received_event_property}
      assert received_event_property == event_property
      assert_receive %{event_property: received_event_property}
      assert received_event_property == event_property
    end

    test "exda will send to all consumers and return an error" do
      Application.put_env(:exda, :consumers,
        message_produced: [
          ExdaTest.UnkownErrorConsumer,
          ExdaTest.TestConsumer
        ]
      )

      event_property = :crypto.strong_rand_bytes(1)

      producer_response =
        ExdaTest.Producer.send_notify_message_produced(%{
          event_property: event_property,
          pid: self()
        })

      assert {:ok,
              [
                {ExdaTest.UnkownErrorConsumer, {:error, unkown_exception}},
                {ExdaTest.TestConsumer, {:ok, :empty}}
              ]} = producer_response

      assert %Exda.Exception.UnkownConsumerError{message: unkown_exception_message} =
               unkown_exception

      assert unkown_exception_message =~ "ExdaTest.UnkownErrorConsumer"
    end
  end
end
