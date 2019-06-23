defmodule ExdaTest.EventBusTest do
  use ExUnit.Case

  describe "synchronous bus" do
    test "should recieve the event from the bus" do
      attribute_value = 1

      Exda.EventBuses.Synchronous.handle_event(:message_produced, ExdaTest.TestConsumer, %{
        pid: self(),
        attribute: attribute_value
      })

      assert_receive %{attribute: received_value}

      assert received_value == attribute_value
    end
  end

  describe "async task bus" do
    test "should recieve the event from the bus" do
      attribute_value = 1

      Exda.EventBuses.AsyncTask.handle_event(:message_produced, ExdaTest.TestConsumer, %{
        pid: self(),
        attribute: attribute_value
      })

      assert_receive %{attribute: received_value}

      assert received_value == attribute_value
    end
  end

  describe "gen server task bus" do
    test "should recieve the event from the bus" do
      attribute_value = 1

      Exda.EventBuses.AsyncCastGenServer.handle_event(
        :message_produced,
        ExdaTest.GenServerConsumer,
        %{pid: self(), attribute: attribute_value}
      )

      assert_receive %{attribute: received_value}

      assert received_value == attribute_value
    end
  end
end
