defmodule GenMcastTest do
  use ExUnit.Case
  doctest GenMcast

  test "what is going on? does not work" do
    alias Experimental.GenStage
    alias GenMcast.{Listener, Producer, Consumer}

    timeout = 2000

    {:ok, _listener} = Listener.start_link

    {:ok, producer} = Producer.start_link
    {:ok, consumer} = Consumer.start_link

    {:ok, _c_prod} = GenStage.sync_subscribe(consumer, to: Producer)

    Producer.run

    Process.send_after producer, :timeout, timeout
    Process.sleep timeout+500
  end

  test "handle_demand is called with GenStage.ask, but consumer does not receive any event" do
    alias Experimental.GenStage
    alias GenMcast.{Listener, Producer, Consumer}

    timeout = 2000

    {:ok, _listener} = Listener.start_link

    {:ok, producer} = Producer.start_link
    {:ok, consumer} = Consumer.start_link

    {:ok, c_prod} = GenStage.sync_subscribe(consumer, to: Producer)

    Producer.run

    :timer.sleep 500
    GenStage.ask({Producer, c_prod}, 10)

    Process.send_after producer, :timeout, timeout
    Process.sleep timeout+500
  end

  test "only works when the subscription happens after the producer is done" do
    alias Experimental.GenStage
    alias GenMcast.{Listener, Producer, Consumer}

    timeout = 2000

    {:ok, _listener} = Listener.start_link

    {:ok, producer} = Producer.start_link
    {:ok, consumer} = Consumer.start_link

    Producer.run
    :timer.sleep 500 # XXX: wait the producer to produce stuff before subcribing
                     #      WHY does it behaves this way??

    {:ok, c_prod} = GenStage.sync_subscribe(consumer, to: Producer)

    Process.send_after producer, :timeout, timeout
    Process.sleep timeout+500
  end
end
