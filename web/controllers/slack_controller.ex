defmodule ArthurFacts.SlackController do
  use ArthurFacts.Web, :controller

  alias ArthurFacts.Fact

  @forbidden_channels ~w(general)

  def get_fact(conn, %{"channel_name" => channel}) when channel in @forbidden_channels do
    resp(conn, 200, "You can't post Arthur facts in #{channel}!")
  end

  def get_fact(conn, %{"text" => text} = params) when not is_nil(text) do
    case String.trim(text) do
      "" -> get_fact(conn, Map.drop(params, ["text"]))
      text -> send_response(text, conn, params)
    end
  end

  def get_fact(conn, params) do
    params
    |> Map.get("channel_name")
    |> Fact.get()
    |> send_response(conn, params)
  end

  defp send_response(fact, conn, params) do
    conn = resp(conn, 204, "")
    HTTPoison.post(params["response_url"], Poison.encode!(%{
      response_type: "in_channel",
      text: fact
    }), [{"Content-Type", "application/json"}])

    conn
  end
end
