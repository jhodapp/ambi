defmodule AmbiWeb.AboutController do
  use AmbiWeb, :controller

  def about(conn, _params) do
    render(conn, "about.html")
  end
end
