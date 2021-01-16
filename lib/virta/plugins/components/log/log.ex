defmodule Virta.Plugins.Component.Log do
  alias Virta.{Port, Component}

  @name "virta:plugins:component:log"

  @settings [
    %Port{
      default: false,
      type: "boolean",
      name: "useStdout",
    }
  ]

  @inports  [
    %Port{
      type: "string",
      name: "message",
      required: true,
    },
  ]
  @outports []

  use Component

  @impl true
  def run(inports, settings, context) do
    message = inports["message"]

    if settings["useStdout"] do
      IO.puts message
    else
      context.logger.log message
    end

    %{}
  end
end