defmodule ArthurFacts.AlexaController do
  use ArthurFacts.Web, :controller

  alias ArthurFacts.Fact

  def get_fact(conn, _params) do
    fact = Fact.get()
    conn
    |> put_resp_content_type("application/json")
    |> resp(200, Poison.encode!(%{
      version: "1.0",
      response: %{
        outputSpeech: %{
          type: "PlainText",
          text: fact
        },
        card: %{
          type: "Simple",
          title: "Arthur Facts",
          content: fact
        }
      }
    }))
  end
end
