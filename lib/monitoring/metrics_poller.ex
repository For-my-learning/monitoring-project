defmodule Monitoring.MetricsPoller do
  use GenServer

  @refresh_ms 5_000

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(state) do
    schedule()
    {:ok, state}
  end

  def get_metrics() do
    GenServer.call(__MODULE__, :get)
  end

  # internal
  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end

  def handle_info(:refresh, _state) do
    new = read_metrics()
    maybe_notify(new)
    schedule()
    {:noreply, new}
  end

  defp schedule(), do: Process.send_after(self(), :refresh, @refresh_ms)

  defp read_metrics() do
    metrics_file = Application.get_env(:monitoring, :metrics_file)
    errors_file = Application.get_env(:monitoring, :errors_file)
    metrics =
      case File.read(metrics_file) do
        {:ok, body} ->
          case Jason.decode(body) do
            {:ok, m} -> m
            _ -> %{}
          end
        _ -> %{}
      end

    errors =
      case File.read(errors_file) do
        {:ok, body} ->
          body
          |> String.split("\n", trim: true)
          |> Enum.take(-20) # last 20 lines
        _ -> []
      end

    Map.put(metrics, "errors", errors)
  end

  # simple notifier state is stored in ETS or Agent; for brevity we do naive per-run notification
  defp maybe_notify(metrics) do
    thresholds = Application.get_env(:monitoring, :thresholds, [])
    webhook = Application.get_env(:monitoring, :notifier)[:webhook_url] || ""

    cond do
      webhook == "" -> :ok
      cpu_high?(metrics, thresholds) -> send_webhook(webhook, "CPU high: #{metrics["cpu"]}%")
      disk_high?(metrics, thresholds) -> send_webhook(webhook, "Disk high: #{metrics["disk"]}%")
      true -> :ok
    end
  end

  defp cpu_high?(%{"cpu" => cpu}, thresholds) when is_number(cpu) do
    cpu > (thresholds[:cpu] || 80.0)
  end
  defp cpu_high?(_, _), do: false

  defp disk_high?(%{"disk" => disk}, thresholds) when is_number(disk) do
    disk > (thresholds[:disk] || 90.0)
  end
  defp disk_high?(_, _), do: false

  defp send_webhook(url, text) do
    payload = Jason.encode!(%{text: text})
    :inets.start()
    :ssl.start()
    headers = [{'Content-Type', 'application/json'}]
    # :httpc requires charlist url
    _ = :httpc.request(:post, {String.to_charlist(url), headers, 'application/json', payload}, [], [])
    :ok
  rescue
    _ -> :ok
  end
end


