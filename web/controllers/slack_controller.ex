defmodule ArthurFacts.SlackController do
  use ArthurFacts.Web, :controller

  alias ArthurFacts.Fact

  @forbidden_channels ~w(general)

  def get_fact(conn, %{"channel_name" => channel}) when channel in @forbidden_channels do
    resp(conn, 200, "You can't post Arthur facts in #{channel}!")
  end

  def get_fact(conn, params) do
    fact =
      params
      |> Map.get("channel_name")
      |> Fact.get()
    conn = resp(conn, 204, "")
    HTTPoison.post(params["response_url"], Poison.encode!(%{
      response_type: "in_channel",
      text: fact
    }), [{"Content-Type", "application/json"}])

    conn
  end
end
