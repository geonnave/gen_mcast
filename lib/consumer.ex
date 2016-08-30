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
    :timer.sleep 500
    {:noreply, [], state}
  end
end
