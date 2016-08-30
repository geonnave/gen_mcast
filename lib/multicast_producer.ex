alias Experimental.GenStage

defmodule GenMcast.MulticastProducer do
  use GenStage

  @mcast_port 49999
  @mcast_group {224,1,1,1}

  def start_link(opts \\ []) do
    GenStage.start_link __MODULE__, "query", name: __MODULE__
  end

  def locate(query \\ "oi") do
    GenStage.cast __MODULE__, {:locate, query}
  end

  def init(query) do
    udp_options = [:binary, reuseaddr: true]
    {:ok, socket} = :gen_udp.open(0, udp_options)
    {:producer, {socket, []}}
  end

  def handle_cast({:locate, query}, state = {socket, []}) do
    :gen_udp.send(socket, @mcast_group, @mcast_port, query)
    {:noreply, [], state}
  end

  def handle_demand(demand, {socket, responses}) when demand > 0 do
    {:noreply, responses, {socket, []}}
  end

  def handle_info({:udp, socket, ip, port, data}, {socket, responses}) do
    resp = [ip, port, data] |> IO.inspect
    new_state = {socket, [resp | responses]}
    {:noreply, [], new_state}
  end

  def handle_info(:timeout, state = {socket, _}) do
    IO.puts "timeout!"
    :gen_udp.close(socket)
    {:stop, :normal, state}
  end
end
