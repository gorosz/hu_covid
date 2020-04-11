defmodule HuCovid.Endpoint do
  use Plug.Router

  plug(Plug.Logger)
  plug(:match)
  plug(Plug.Parsers, parsers: [:json], json_decoder: Jason)
  plug(:dispatch)

  get "/ping" do
    send_resp(conn, 200, "pong")
  end

  get "/hu_data" do
    resp_body = HuCovid.get_data()
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, resp_body)
  end

  match _ do
    send_resp(conn, 404, "Hoops")
  end
end
