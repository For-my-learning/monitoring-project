defmodule MonitoringWeb.MetricsController do
  use MonitoringWeb, :controller

  def index(conn, _params) do
    metrics = Monitoring.MetricsPoller.get_metrics()
    json(conn, metrics)
  end
end


