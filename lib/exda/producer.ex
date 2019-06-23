defmodule Exda.Producer do
  @type bus_callback() :: {:ok, any()} | {:error, any()} | {:halt, any()} | :error | :ok | :halt

  @type bus_success() :: {:ok, pid()} | {:ok, :empty} | {:ok, any()}
  @type bus_failure() :: {:error, %Exda.Exception.UnkownConsumerError{}} | {:error, any()}
  @type bus_halt() :: {:halt, %Exda.Exception.UnkownConsumerHalt{}} | {:halt, any()}

  @type bus_responses() :: list({module(), bus_success() | bus_failure() | bus_halt()})

  @type producer_response() :: {:ok, bus_responses()}

  @moduledoc """

    Producers should be used to generate convience methods(:notify_{event_name}) to produce messages
    for all the attached consumer.

    

  """
  defmacro __using__(events \\ []) do
    ast_consumers =
      quote do
        defp handle_single_consumer({consumer, bus}, event_name, event_data),
          do: apply(bus, :handle_event, [event_name, consumer, event_data])

        defp handle_single_consumer({consumer}, event_name, event_data) do
          # fetch the default event bus or fallback to the Synchronous Bus
          Application.get_env(:exda, :bus, Exda.EventBuses.Synchronous)
          |> apply(:handle_event, [event_name, consumer, event_data])
        end

        defp handle_single_consumer(consumer, event_name, event_data)
             when is_atom(consumer) and is_atom(event_name) do
          handle_single_consumer({consumer}, event_name, event_data)
        end

        defp handle_single_consumer(_, event_name, event_data), do: {:error, :invalid_consumer}

        defp get_consumer_from_tuple({consumer, bus}), do: consumer
        defp get_consumer_from_tuple({consumer}), do: consumer
        defp get_consumer_from_tuple(consumer) when is_atom(consumer), do: consumer
      end

    ast_notify_functions =
      for generating_event_name <- events do
        quote do
          @spec unquote(:"notify_#{generating_event_name}")(arguments :: Keyword.t()) ::
                  Exda.Producer.bus_response()
          defp unquote(:"notify_#{generating_event_name}")(event_data) do
            consumers =
              Keyword.get(
                Application.get_env(:exda, :consumers, []),
                unquote(generating_event_name),
                []
              )

            consumer_responses =
              Enum.reduce_while(consumers, [], fn consumer, acc ->
                consumer_module = get_consumer_from_tuple(consumer)

                case handle_single_consumer(consumer, unquote(generating_event_name), event_data) do
                  :ok ->
                    {:cont, [{consumer_module, {:ok, :empty}} | acc]}

                  :error ->
                    {:cont,
                     [
                       {consumer_module,
                        {:error,
                         %Exda.Exception.UnkownConsumerError{
                           message: "unkown error with consumer: #{consumer}"
                         }}}
                       | acc
                     ]}

                  :halt ->
                    {:halt,
                     [
                       {consumer_module,
                        {:error,
                         %Exda.Exception.UnkownConsumerHalt{
                           message: "halt by consumer: #{consumer}"
                         }}}
                       | acc
                     ]}

                  {:ok, result} ->
                    {:cont, [{consumer_module, {:ok, result}} | acc]}

                  {:error, err} ->
                    {:cont, [{consumer_module, {:error, err}} | acc]}

                  {:halt, error} ->
                    {:halt, [{consumer_module, {:error, error}} | acc]}

                  _ ->
                    {:cont, [{consumer_module, {:error, :invalid_response}} | acc]}
                end
              end)

            {:ok, Enum.reverse(consumer_responses)}
          end
        end
      end

    [ast_consumers | ast_notify_functions]
  end
end
