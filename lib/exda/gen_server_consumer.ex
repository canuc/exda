defmodule Exda.GenServerConsumer do
  @moduledoc """

  This GenServerConsumer is used by specifying the event names
  that can be processed by this event. to as well as a restart type which will
  be used to create a child spec for any module uses `GenServerConsumer`.

  ## Using

  To create a module that is suitable to be put into a supervisor you should use:

      defmodule SomeApp.SomeModule do
        use Exda.GenServerConsumer, [:message_sent]

        @impl true
        def handle_message_sent(event_data) do
          Logger.info("Got event!")

          :ok
        end
      end

  To create a GenServer that will be lazily started upon the first message produced.

  This consumer type will only be necessary if an only if you are using the 
  `AsyncCastGenServer` bus.

  ## Event Consumer

  Based on the above configuration you will need to declare a function: `handle_message_sent/1`
  that will process each individual recieved message.

  """
  defmacro __using__(events \\ []) do
    gen_server_ast =
      quote do
        use Exda.Consumer, unquote(events)

        use GenServer, restart: :permanent

        def start_link(_) do
          GenServer.start_link(__MODULE__, [])
        end

        def init(opts \\ []) do
          {:ok, opts}
        end
      end

    events_ast =
      for event_name <- events do
        quote do
          def handle_cast({:consume_event, unquote(event_name), event_data}, state) do
            apply(__MODULE__, :"consume_#{unquote(event_name)}", [event_data])

            {:noreply, state}
          end
        end
      end

    fallback_events =
      quote do
        def handle_cast(_, state) do
          {:noreply, state}
        end
      end

    [gen_server_ast | events_ast] ++ [fallback_events]
  end
end
