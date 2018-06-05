defmodule ArthurFacts.SlackController do
  use ArthurFacts.Web, :controller

  alias ArthurFacts.Fact

  def get_fact(conn, _params) do
    fact = Fact.get()
    conn
    |> put_resp_content_type("application/json")
    |> resp(200, Poison.encode!(%{
      response_type: "in_channel",
      text: fact
    }))
  end
end
