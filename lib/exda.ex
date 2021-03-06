defmodule Exda do
  @moduledoc """

  # Exda = Elixir EDA. 

  ## Easily decouple elixir components.

  This library's purpose is to allow a user to decouple components within their application via EDA.

  EDA is event driven architecture, that encourages smaller more testable and easily maintainable
  contexts.

  This library was inspired by a talk at [ElixirConf EU 2018](https://www.youtube.com/watch?v=8qDXG7tnl9w).

  The event bus will be configurable at build time based on environment config. 
  This makes it possible to factor out business logic so that your functional code
  is testable.

  To use Exda you must intialize a list of possible broadcast event names. Currently event
  names are atoms, whos names should be verbs describing the action that produces the event.

  Some examples: 

    * `:messsage_sent`
    * `:message_received`

  ## Producers

  Producers are the modules that report that an action has been completed. Let's say you have 
  just sent, recieved and persisted a message from a phoenix channel, and want to let some other modules
  handle subsequent actions. We can publish the event to all the hooked up consumers with the 
  call: `notify_message_produced/1`.


      defmodule SomeApp.UserChannel do
        ##
        ## This will define a function: `notify_message_produced`
        ##
        use Exda.Producer, [:message_produced]

        ...

        def handle_in("users:message:" <> topic_id, payload, socket) do

          ...

          notify_message_produced(%{to: to, from: from, time_spent_processing: 100_000})
        end
      end


  ## Consumers

  A consumer is a module that maintains one callback for each event name. Each callback should be of the form:
  `consume_${event_name}`. The callback will be invoked once per call to a producers notify.

  To attach a consumer to an event, simply configure the event with a list of tuples. First element being
  the module, second being the bus. For the example the config for a `:message_produced` event could be 
  as follows:


      config :exda, [
        events: [:message_produced, :message_received],
        consumers: [
          message_produced: [
            {SomeApp.SomeModule, Exda.EventBuses.Synchronous},
            {SomeApp.OtherModule, Exda.EventBuses.AsyncTask},
            {SomeApp.ThirdModule, Exda.EventBuses.AsyncCastGenServer}
          ],
          message_received: [SomeApp.FourthModule]
        ]
      ]


  The configuration above will trigger: `SomeApp.SomeModule.consume_message_produced/1` synchronously,
  `SomeApp.OtherModule.consume_message_produced/1` asynchronously, and send a message to a GenServer
  which auto-magically routes to the method: `SomeApp.ThirdModule.consume_message_produced/1`.

  This customization means you can have control of the delivery bus based on your config. In your
  config for tests you can remove all the consumers that reach out to external API or make long running
  calls.

  ## Events

  The events key of the configuration:

      config :exda, [
        events: [:message_produced, :message_received],
      ]


  is a list of all the possible events that are available in your application. With the above 
  configuration, we could create consumers: 

      defmodule SomeApp.SomeModule do
        use Exda.Consumer, [:message_sent]

        @impl true
        def consume_message_sent(event_data) do
          Logger.info("Got event!")

          :ok
        end
      end


  and 
   
      defmodule SomeApp.FourthModule do
        use Exda.Consumer, [:message_recieved]

        @impl true
        def consume_message_recieved(event_data) do
          Logger.info("Got event!")

          :ok
        end
      end


    
  ## Buses

  A bus will change how the event is delivered. The interface for the event handling
  module will mostly stay the same(the only exception bieng `Exda.AsyncCastGenServer`) which will
  will require you to change from: `use Exda.Consumer, [:message_recieved]` to: `use Exda.GenServerConsumer, [:message_recieved]`.

  There are a few ways for an event to be delivered:

    * `Exda.EventBuses.Synchronous` - This bus will simply call the event consumer synchronously.

    * `Exda.EventBuses.AsyncTask` - This will use `Task.start/3` and call each specified consumer as
      a new task with its own pid.

    * `Exda.EventBuses.AsyncCastGenServer` - This will call a `GenServer` resulting in all message
      being processed in its own pid asynchronously.


  ## Exda.EventBuses.Synchronous

  This bus will fire off all the connections in the current pid. This is the default, so if there is
  no bus information is provided then all consumers will be invoked within the producer's process and 
  block execution.

  ## Exda.EventBuses.AsyncTask

  This bus will fire in an async task. invoked with start, this means that every consumer will
  be invoked in its own pid. This can be useful for tasks that need to be fire and forget and 
  do not need to be linked.

  ## Exda.EventBuses.AsyncCastGenServer

  This bus requires that any consumers `use Exda.GenServerConsumer`. This bus is useful if 
  you want to have a specific number of pids that are dedicated to consuming messages. 

  Please see: `Exda.EventBuses.AsyncCastGenServer`

  As well with the `Exda.EventBuses.AsyncCastGenServer` bus you can add the module to your supervisor tree.


  ## Example

  There is an example in the example folder.

  """
  for event_name <- Application.get_env(:exda, :events, []) do
    ast =
      quote do
        @callback unquote(:"consume_#{event_name}")(event :: Keyword.t()) :: :ok | :halt | :error
      end

    Module.create(
      :"Elixir.Exda.#{Macro.camelize(Atom.to_string(event_name))}Consumer",
      ast,
      Macro.Env.location(__ENV__)
    )
  end
end
