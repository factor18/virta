defmodule Virta.Core.In do
  def loop(inport_args, outport_args, instance_pid) do
    receive do
      { :inflate, value } when is_map(value) ->
        run(value, outport_args, instance_pid)
      { port, value } ->
        inport_args = Map.put(inport_args, port, value)
        required_fields = Enum.map(outport_args, fn(arg) -> Map.get(arg, :to) end)
        if(required_fields |> Enum.all?(&(Map.has_key?(inport_args, &1)))) do
          run(inport_args, outport_args, instance_pid)
          loop(%{}, outport_args, instance_pid)
        else
          loop(inport_args, outport_args, instance_pid)
        end
    end
  end

  def run(inport_args, outport_args, _instance_pid) do
    Enum.map(outport_args, fn(arg) ->
      %{ to: port, pid: pid } = arg
      send(pid, { port , Map.get(inport_args, port) })
    end)
  end
end