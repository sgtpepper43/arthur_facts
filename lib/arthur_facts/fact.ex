defmodule ArthurFacts.Fact do
  use GenServer

  alias CacheMoney.Adapters.ETS

  # Timeout is in seconds
  @timeout 60 * 60 * 12
  @limit_timeout 60 * 60 * 4 # four hours
  @purge_frequency 60 * 5 # five minutes
  @cache_opts %{
    adapter: ETS, purge_frequency: @purge_frequency
  }

  defp fact_url, do: Application.get_env(:arthur_facts, :fact_url)

  def get(key \\ "default", limitted_keys \\ []) do
    {:ok, pid} =
      with pid when not is_nil(pid) <- Process.whereis(__MODULE__),
           true <- Process.alive?(pid) do
        {:ok, pid}
      else
        _ -> GenServer.start_link(__MODULE__, nil, name: __MODULE__)
      end

    GenServer.call(pid, {:get, key, limitted_keys})
  end

  @impl true
  def init(_) do
    CacheMoney.start_link(:fact_cache, @cache_opts)
  end

  @impl true
  def handle_call({:get, key, limitted_keys}, _from, cache) do
    [fact | facts] = get_facts(cache, key)
    IO.inspect(length(facts), label: "facts")
    if limit?(cache, key, limitted_keys) do
      {:reply, :limit, cache}
    else
      {:reply, fact, cache}
    end
  end

  def handle_call({:cache}, _from, cache) do
    {:reply, cache, cache}
  end

  defp limit?(cache, key, limitted_keys) do
    if Enum.member?(limitted_keys, key) do
      case CacheMoney.get(cache, "#{key}-limit") do
        {:ok, nil} ->
          CacheMoney.set(cache, "#{key}-limit", true, @limit_timeout)
          false
        _ -> true
      end
    else
      false
    end
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
