alias Experimental.GenStage

defmodule GenMcast.Producer do
  use GenStage

  def start_link(opts \\ [ip_addr: "224.1.1.1", port: 49999]) do
    {:ok, ip_addr} = opts[:ip_addr] |> String.to_char_list |> :inet.parse_address
    opts = put_in opts[:ip_addr], ip_addr
    GenStage.start_link __MODULE__, opts, name: __MODULE__
  end

  def run(msg \\ "msg") do
    GenStage.cast __MODULE__, {:run, msg}
  end

  # GenStage callbacks

  def init(opts) do
    udp_options = [:binary, reuseaddr: true]
    {:ok, socket} = :gen_udp.open(0, udp_options)
    {:producer, {socket, opts}}
  end

  @doc """
  Will produce for the required demand! XXX: but not today :C
  """
  def handle_demand(demand, state) when demand > 0 do
    {:noreply, [], state}
  end

  @doc """
  This is a normal :gen_udp callback that receives a udp response and
  sends it to a consumer as an event.
  """
  def handle_info({:udp, socket, ip, port, data}, state) do
    {:noreply, [{ip, port, data}], state}
  end

  def handle_info(:timeout, state = {socket, _}) do
    IO.puts "timeout!"
    :gen_udp.close(socket)
    {:stop, :normal, state}
  end

  def handle_cast({:run, msg}, state = {socket, opts}) do
    :gen_udp.send(socket, opts[:ip_addr], opts[:port], msg)
    {:noreply, [], state}
  end
end
