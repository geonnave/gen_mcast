defmodule GenMcastTest do
  use ExUnit.Case
  doctest GenMcast

  test "general" do
    alias Experimental.GenStage
    alias GenMcast.{Listener, Producer, Consumer}

    timeout = 2000

    {:ok, _listener} = Listener.start_link

    {:ok, producer} = Producer.start_link
    {:ok, consumer} = Consumer.start_link
    :timer.sleep 100

    {:ok, _c_prod} = GenStage.sync_subscribe(consumer, to: producer)

    Process.send_after producer, :timeout, timeout
    Process.sleep timeout+500
  end
end
