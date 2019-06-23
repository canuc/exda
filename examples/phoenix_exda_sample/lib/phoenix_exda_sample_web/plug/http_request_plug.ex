defmodule PhoeonixExdaSample.Plug.HttpRequestPlug do
    require Logger
    alias Plug.Conn
    use Exda.Producer, [:http_request_processed]
    @behaviour Plug
  
    def init(opts) do
      Keyword.get(opts, :log, :info)
    end
  
    def call(conn, level) do
      Logger.log(level, fn ->
        [conn.method, ?\s, conn.request_path]
      end)
  
      start = System.monotonic_time()
  
      Conn.register_before_send(conn, fn conn ->
        stop = System.monotonic_time()
        diff = System.convert_time_unit(stop - start, :native, :microsecond)
        status = Integer.to_string(conn.status)

        Logger.log(level, fn ->
          [connection_type(conn), ?\s, status, " in ", formatted_diff(diff)]
        end)
  
        notify_http_request_processed([
          request_time: diff,
          status: status,
          method: conn.method,
          request_path: conn.request_path
        ])
        conn
      end)
    end
  
    defp formatted_diff(diff) when diff > 1000, do: [diff |> div(1000) |> Integer.to_string(), "ms"]
    defp formatted_diff(diff), do: [Integer.to_string(diff), "µs"]
  
    defp connection_type(%{state: :set_chunked}), do: "Chunked"
    defp connection_type(_), do: "Sent"
  end