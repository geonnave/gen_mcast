defmodule GenMcast.Listener do
  use GenServer

  @mcast_port 49999
  @mcast_group {224,1,1,1}

  def start_link(opts \\ []) do
    GenServer.start_link __MODULE__, opts, name: __MODULE__
  end

  def init(_) do
    udp_options = [
      :binary,
      active: 10,
      add_membership:  {@mcast_group, {0,0,0,0}},
      multicast_if:    {0,0,0,0},
      multicast_loop:  false,
      multicast_ttl:   2,
      reuseaddr:       true
    ]

    {:ok, _socket} = :gen_udp.open(@mcast_port, udp_options)
  end

  def handle_info({:udp, socket, ip, port, data}, state) do
    # when we popped one message we allow one more to be buffered
    :inet.setopts(socket, [active: 1])
    IO.puts "in listener: #{inspect {ip, port, data}}!"

    udp_options = [:binary, reuseaddr: true]
    {:ok, sock} = :gen_udp.open(0, udp_options)
    :gen_udp.send(sock, ip, port, "bye!")
    :gen_udp.send(sock, ip, port, "bye2!")
    :gen_udp.send(sock, ip, port, "bye33!")
    :gen_udp.close(sock)

    {:noreply, state}
  end
end

# Broker.Locate.MulticastListener.start_link
# Process.sleep(:infinity)
