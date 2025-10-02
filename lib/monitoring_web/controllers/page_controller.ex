defmodule MonitoringWeb.PageController do
  use MonitoringWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
