alias Experimental.GenStage

defmodule GenMcast.Producer do
  use GenStage

  @mcast_port 49999
  @mcast_group {224,1,1,1}

  def start_link(opts \\ []) do
    GenStage.start_link __MODULE__, "msg", name: __MODULE__
  end

  # GenStage callbacks

  def init(msg) do
    udp_options = [:binary, reuseaddr: true]
    {:ok, socket} = :gen_udp.open(0, udp_options)
    :gen_udp.send(socket, @mcast_group, @mcast_port, msg)
    {:producer, {socket, []}}
  end

  @doc """
  This is a normal :gen_udp callback that receives back a message. The
  idea is that the responses are accumulated in the `state`; this way,
  the responses are only consumed when there is demand for it.
  """
  def handle_info({:udp, socket, ip, port, data}, _state = {socket, responses}) do
    resp = [ip, port, data]
    new_state = {socket, [resp | responses]}
    # {:noreply, [resp], new_state}
    {:noreply, [], new_state}
  end

  @doc """
  Will produce for the required demand!
  """
  def handle_demand(demand, {socket, responses}) when demand > 0 do
    IO.puts "there is demand: #{demand}!"
    {events, responses} = Enum.split(responses, demand)
    # {:noreply, [], {socket, responses}}
    {:noreply, events, {socket, responses}}
  end

  def handle_info(:timeout, state = {socket, _}) do
    IO.puts "timeout!"
    :gen_udp.close(socket)
    {:stop, :normal, state}
  end
end
