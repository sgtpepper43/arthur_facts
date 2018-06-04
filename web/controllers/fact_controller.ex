defmodule ArthurFacts.FactController do
  use ArthurFacts.Web, :controller

  alias ArthurFacts.Fact

  def get_fact(conn, _params) do
    resp(conn, 200, Fact.get())
  end
end
