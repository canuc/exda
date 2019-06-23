
  defmodule ExdaTest.Producer do
    use Exda.Producer, [:message_produced]

    def send_notify_message_produced(message) do
      notify_message_produced(message)
    end
  end