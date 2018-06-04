defmodule ArthurFacts.FactController do
  use ArthurFacts.Web, :controller

  alias ArthurFacts.Fact

  def get_fact(conn, _params) do
    fact = Fact.get()
    resp(conn, 200, Poison.encode!(%{
      version: "1.0",
      response: %{
        outputSpeech: %{
          type: "PlainText",
          text: fact
        }
      }
    }))
  end
end
