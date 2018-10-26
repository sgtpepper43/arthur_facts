defmodule ArthurFacts.SlackController do
  use ArthurFacts.Web, :controller

  alias ArthurFacts.Fact

  @forbidden_channels ~w(general)
  @limitted_channels ~w(engineering utahoffice)
  @custom_text_users ~w(trevor james jbrand dennis.beatty korndog kory jake.oldham)

  def get_fact(conn, %{"channel_name" => channel}) when channel in @forbidden_channels do
    resp(conn, 200, "You can't post Arthur facts in #{channel}!")
  end

  def get_fact(conn, %{"text" => text, "user_name" => user_name} = params)
      when not is_nil(text) and user_name in @custom_text_users do
    case String.trim(text) do
      "" -> get_fact(conn, Map.drop(params, ["text"]))
      text -> send_response(text, conn, params)
    end
  end

  def get_fact(conn, %{"channel_name" => channel} = params) do
    case Fact.get(channel, @limitted_channels) do
      :limit ->
        resp(conn, 200, "Too many Arthur facts have been posted in #{channel}! Give it a minute!")
      fact ->
        send_response(fact, conn, params)
    end
  end

  defp send_response(fact, conn, params) do
    conn = resp(conn, 204, "")

    HTTPoison.post(
      params["response_url"],
      Poison.encode!(%{
        response_type: "in_channel",
        text: fact
      }),
      [{"Content-Type", "application/json"}]
    )

    conn
  end
end
