defmodule ArthurFacts.Fact do
  use GenServer

  @timeout 1000 * 60 * 10 # ten minute timeout

  defp fact_url, do: Application.get_env(:arthur_facts, :fact_url)

  def get do
    {:ok, pid} =
      with pid when not is_nil(pid) <- Process.whereis(__MODULE__),
           true <- Process.alive?(pid) do
        {:ok, pid}
      else
        _ -> GenServer.start_link(__MODULE__, nil, name: __MODULE__)
      end

    GenServer.call(pid, :get)
  end

  @impl true
  def init(_) do
    Process.send_after(self(), :timeout, @timeout)
    {:ok, refresh_facts([])}
  end

  @impl true
  def handle_call(:get, _from, [fact | facts]) do
    {:reply, fact, refresh_facts(facts)}
  end

  @impl true
  def handle_info(:timeout, _) do
    {:stop, :normal, nil}
  end

  defp refresh_facts(facts) when length(facts) < 5, do: get_facts(facts)

  defp refresh_facts(facts), do: facts

  defp get_facts([]), do: get_facts(["Arthur is from New Mexico"])

  defp get_facts(facts) do
    case HTTPoison.get(fact_url()) do
      {:ok, %{body: fact_resp}} ->
        fact_resp
        |> String.split("\n")
        |> Enum.shuffle()
      _ -> facts
    end
  end
end
