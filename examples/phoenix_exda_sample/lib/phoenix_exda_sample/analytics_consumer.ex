defmodule PheonixExdaSample.AnalyticsConsumer do
  use Exda.GenServerConsumer, [:http_request_processed, :user_index_requested]
  require Logger

  def consume_http_request_processed(event) do
    Logger.info("Processing :http_request_processed event: #{inspect event}")

    :ok
  end

  def consume_user_index_requested(event) do
    Logger.info("Processing :consume_user_index_requested event: #{inspect event}")

    :ok
  end
end