defmodule ArthurFacts.SlackController do
  use ArthurFacts.Web, :controller

  alias ArthurFacts.Fact

  def get_fact(conn, _params) do
    fact = Fact.get()
    conn
    |> put_resp_content_type("text/plain")
    |> resp(200, fact)
  end
end
