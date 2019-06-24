# PhoenixExdaSample

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).


## Exda

To check out how exda was added:

```
  mix.exs
     {:exda, path: "../../"}
```

A listing of all the events that we will be using in the project is configured in `config.exs`:

```
    config :exda, events: [:http_request_processed, :user_index_requested]
```

A listing of the consumers used outside of testing has been factored out to `config/production_consumers.exs`

```
    config :exda, consumers: [
      http_request_processed: [
        {PheonixExdaSample.AnalyticsConsumer, Exda.EventBuses.AsyncCastGenServer}
      ],
      user_index_requested: [
        {PheonixExdaSample.AnalyticsConsumer, Exda.EventBuses.AsyncCastGenServer}
      ]
    ]
```

The consumer has two functions: `PheonixExdaSample.AnalyticsConsumer.consume_http_request_processed/1` and
`PheonixExdaSample.AnalyticsConsumer.consume_user_index_requested/1`, that simply log message when the 
server receives the messages.


```
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
```



## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
