defmodule ArthurFacts.Router do
  use ArthurFacts.Web, :router

  pipeline :alexa_api do
    plug :accepts, ["json"]
    plug AlexaRequestVerifier
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api/facts", ArthurFacts do
    pipe_through :alexa_api

    post "/", AlexaController, :get_fact
  end

  scope "/api/slack", ArthurFacts do
    pipe_through :api

    get "/", SlackController, :get_fact
  end
end
