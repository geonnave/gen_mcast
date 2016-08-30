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
    {:producer, {socket, opts, []}}
  end

  @doc """
  Will produce for the required demand!
  XXX: does not work :C
  """
  def handle_demand(demand, {socket, opts, responses}) when demand > 0 do
    IO.puts "there is demand: #{demand}! responses is: #{inspect responses}"
    {events, rem_responses} = Enum.split(responses, demand) # send no more events than required

    {:noreply, events, {socket, opts, rem_responses}}
  end

  @doc """
  This is a normal :gen_udp callback that receives back a message. The
  idea is that the responses are accumulated in the `state`; this way,
  the responses are only consumed when there is demand for it.
  """
  def handle_info({:udp, socket, ip, port, data}, _state = {socket, opts, responses}) do
    resp = {ip, port, data}
    new_state = {socket, opts, [resp | responses]} # accumulating the responses in the state

    {:noreply, [], new_state}
  end

  def handle_info(:timeout, state = {socket, _, _}) do
    IO.puts "timeout!"
    :gen_udp.close(socket)
    {:stop, :normal, state}
  end

  def handle_cast({:run, msg}, state = {socket, opts, _}) do
    :gen_udp.send(socket, opts[:ip_addr], opts[:port], msg)
    {:noreply, [], state}
  end
end
