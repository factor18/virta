defmodule Flo.Graph do
  @moduledoc false

  alias Flo.{Workflow, Connection}

  def new(%Workflow{} = workflow) do
    workflow
    |> Map.get(:connections)
    |> Enum.reduce(
      Graph.new(type: :directed),
      fn %Connection{source: source, destination: destination, outcome: outcome}, graph ->
        graph |> Graph.add_edge(source, destination, label: outcome)
      end
    )
  end

  def root(graph) do
    Graph.topsort(graph) |> List.first()
  end

  defdelegate next(graph, element), to: Graph, as: :out_neighbors

  defdelegate prev_connections(graph, element), to: Graph, as: :in_edges

  defdelegate next_connections(graph, element), to: Graph, as: :out_edges
end
