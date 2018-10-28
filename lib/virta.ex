defmodule Virta do
  alias Virta.Node
  alias Virta.Registry
  alias Virta.EdgeData
  alias Virta.Instance
  alias Virta.Supervisor

  use Application

  def start(_type, _args) do
    Supervisor.start_link(name: Supervisor)
  end

  def run do
    graph = Graph.new(type: :directed)
    |> Graph.add_edge(
      %Node{ module: "Virta.Core.In", id: 0 },
      %Node{ module: "Virta.Math.Add", id: 1 },
      label: %EdgeData{ from: :addend, to: :addend }
    )
    |> Graph.add_edge(
      %Node{ module: "Virta.Core.In", id: 0 },
      %Node{ module: "Virta.Math.Add", id: 1 },
      label: %EdgeData{ from: :augend, to: :augend }
    )
    |> Graph.add_edge(
      %Node{ module: "Virta.Math.Add", id: 1 },
      %Node{ module: "Virta.Math.Add", id: 3 },
      label: %EdgeData{ from: :sum, to: :addend }
    )
    |> Graph.add_edge(
      %Node{ module: "Virta.Math.Add", id: 1 },
      %Node{ module: "Virta.Math.Add", id: 3 },
      label: %EdgeData{ from: :sum, to: :augend }
    )
    |> Graph.add_edge(
      %Node{ module: "Virta.Math.Add", id: 3 },
      %Node{ module: "Virta.Math.Add", id: 5 },
      label: %EdgeData{ from: :sum, to: :addend }
    )
    |> Graph.add_edge(
      %Node{ module: "Virta.Math.Add", id: 3 },
      %Node{ module: "Virta.Math.Add", id: 5 },
      label: %EdgeData{ from: :sum, to: :augend }
    )
    |> Graph.add_edge(
      %Node{ module: "Virta.Math.Add", id: 5 },
      %Node{ module: "Virta.Core.Out", id: 7 },
      label: %EdgeData{ from: :sum, to: :sum }
    )

    unless Graph.is_cyclic?(graph) do
      name = "adder"
      Registry.register(name, graph)
      Registry.get(name)

      Enum.each(1..100000, fn i ->
        data = %{
          %Node{ module: "Virta.Core.In", id: 0 } => [{ i, :augend, i }, { i, :addend,  i*2 }]
        }

        :poolboy.transaction(String.to_existing_atom(name), fn (server) ->
          Instance.execute(server, data)
          receive do
            message -> IO.inspect(message)
          end
        end)

      end)
    else
      raise "Graph is expected to be acyclic"
    end
  end
end
