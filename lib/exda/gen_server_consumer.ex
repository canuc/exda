defmodule Exda.GenServerConsumer do
  defmacro __using__(events \\ [], restart_type \\ :transient) do
    gen_server_ast =
      quote do
        use Exda.Consumer, unquote(events)

        use GenServer, restart: unquote(restart_type)

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
