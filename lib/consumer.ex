alias Experimental.GenStage

defmodule GenMcast.Consumer do
  use GenStage

  def start_link(_opts \\ []) do
    GenStage.start_link __MODULE__, []
  end

  def init(_) do
    {:consumer, []}
  end

  def handle_events(new_services, _from, state) do
    IO.puts "in consumer: #{inspect new_services}"
    {:noreply, [], state}
  end
end

alias GenMcast.{Listener, Producer, Consumer}
timeout = 1000

{:ok, _listener} = Listener.start_link

{:ok, producer} = Producer.start_link
{:ok, consumer} = Consumer.start_link

{:ok, c_prod} = GenStage.sync_subscribe(consumer, to: producer)

Process.send_after producer, :timeout, timeout
Process.sleep timeout+500
