defmodule Exda.Consumer do
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
