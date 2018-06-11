defmodule ArthurFacts.Fact do
  use GenServer

  alias CacheMoney.Adapters.ETS

  # Timeout is in seconds
  @timeout 60 * 60 * 12

  defp fact_url, do: Application.get_env(:arthur_facts, :fact_url)

  def get(key \\ "default") do
    {:ok, pid} =
      with pid when not is_nil(pid) <- Process.whereis(__MODULE__),
           true <- Process.alive?(pid) do
        {:ok, pid}
      else
        _ -> GenServer.start_link(__MODULE__, nil, name: __MODULE__)
      end

    GenServer.call(pid, {:get, key})
  end

  @impl true
  def init(_) do
    CacheMoney.start_link(:fact_cache, %{adapter: ETS})
  end

  @impl true
  def handle_call({:get, key}, _from, cache) do
    [fact | facts] = get_facts(cache, key)
    IO.inspect(length(facts), label: "facts")
    {:reply, fact, cache}
  end


  defp get_facts(cache, key) do
    case CacheMoney.get(cache, key) do
      {:ok, nil} ->
        [fact | facts] = fetch_facts()
        CacheMoney.set(cache, key, facts, @timeout)
        [fact | facts]
      {:ok, facts} when length(facts) < 5 ->
        [fact | facts] = facts
        CacheMoney.set(cache, key, facts, @timeout)
        Task.start_link(fn ->
          CacheMoney.set(cache, key, fetch_facts(), @timeout)
        end)
        [fact | facts]
      {:ok, [fact | facts]} ->
        CacheMoney.set(cache, key, facts, @timeout)
        [fact | facts]
    end
  end

  defp fetch_facts do
    case HTTPoison.get(fact_url()) do
      {:ok, %{body: fact_resp}} ->
        fact_resp
        |> String.replace("\uFEFF", "")
        |> String.split("\r\n")
        |> Enum.shuffle()
      _ -> ["Arthur is from New Mexico", "Arthur might be right handed"]
    end
  end
end
