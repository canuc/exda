defmodule Exda.Consumer do
  @moduledoc """

  Use this consumer module whenever you would like to provision a module to
  accept events from a producer.

  Lets say we wanted to process an event: `:message_sent`.

  The consumer would look a little something like:

      defmodule SomeApp.SomeModule do
        use Exda.Consumer, [:message_sent]

        @impl true
        def consume_message_sent(event_data) do
          Logger.info("Handling event! ")

          event_data
          |> IO.inspect

          :ok
        end
      end


  """
  defmacro __using__(events \\ []) do
    for generating_event_name <- events do
      quote do
        @behaviour unquote(
                     :"Elixir.Exda.#{Macro.camelize(Atom.to_string(generating_event_name))}Consumer"
                   )
      end
    end
  end
end
