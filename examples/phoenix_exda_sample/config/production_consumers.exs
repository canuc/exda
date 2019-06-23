use Mix.Config

config :exda, consumers: [
  http_request_processed: [
    {PheonixExdaSample.AnalyticsConsumer, Exda.EventBuses.AsyncCastGenServer}
  ],
  user_index_requested: [
    {PheonixExdaSample.AnalyticsConsumer, Exda.EventBuses.AsyncCastGenServer}
  ]
]
