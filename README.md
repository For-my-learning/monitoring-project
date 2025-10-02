# Monitoring

To start your Phoenix server:

* Run `mix setup` to install and setup dependencies
* Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

* Official website: https://www.phoenixframework.org/
* Guides: https://hexdocs.pm/phoenix/overview.html
* Docs: https://hexdocs.pm/phoenix
* Forum: https://elixirforum.com/c/phoenix-forum
* Source: https://github.com/phoenixframework/phoenix
# Monitoring Project (Mini)

## 概要
Linux サーバの CPU、メモリ、ディスク使用量、最新エラー情報を収集し、Web API で確認できるとともに、閾値を超えた場合に Slack に通知するシステム。

- Bash スクリプトでサーバメトリクス収集
- Phoenix アプリで `/metrics` API と簡易ダッシュボード表示
- Slack Webhook による閾値通知
- Docker 化でどこでも同じ環境で実行可能

---

---

## ローカル実行

1. metrics collector を手動で動かす（または cron）

```bash
bash scripts/collect_metrics.sh

Phoenix サーバを起動

cd monitoring
mix deps.get
export NOTIFIER_WEBHOOK_URL="https://hooks.slack.com/services/XXXXX/XXXXX/XXXXX"
mix phx.server

ブラウザでアクセス

http://localhost:4000/


/metrics で JSON データを確認可能

/ で簡易ダッシュボード表示


Docker で実行

イメージビルド

cd monitoring
docker build -t monitoring-app .


コンテナ起動（データディレクトリをマウント）

docker run -p 4000:4000 \
  -v ~/monitoring-project/data:/app/../data \
  -e NOTIFIER_WEBHOOK_URL="https://hooks.slack.com/services/XXXXX/XXXXX/XXXXX" \
  monitoring-app


ブラウザで http://localhost:4000/ にアクセス可能

metrics.json はホスト側に保存され、リアルタイムに反映

Cron で定期収集（推奨）

毎分 metrics.json を更新する例：

* * * * * /home/youruser/monitoring-project/scripts/collect_metrics.sh >> /home/youruser/monitoring-project/logs/metrics.log 2>&1

