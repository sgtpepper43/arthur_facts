defmodule ArthurFacts.SlackController do
  use ArthurFacts.Web, :controller

  alias ArthurFacts.Fact

  def get_fact(conn, params) do
    fact = Fact.get()
    conn = resp(conn, 204, "")
    IO.inspect(params, label: "params")
    HTTPoison.post(params.response_url, Poison.encode!(%{
      response_type: "in_channel",
      text: fact
    }), [{"Content-Type", "application/json"}]) |> IO.inspect(label: "post")

    conn
  end
end
