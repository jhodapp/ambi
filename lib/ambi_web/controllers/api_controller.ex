defmodule AmbiWeb.ApiController do
  use AmbiWeb, :controller

  def add_reading(conn, params) do
    Ambi.add_reading(params)

    status = %{code: "ok", desc: "Reading inserted successfully into DB"}
    render(conn, "api_response.json", status: status)
  end
end
