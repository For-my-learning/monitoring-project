# Monitoring Project 

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
```

Phoenix サーバを起動

cd monitoring
mix deps.get
export NOTIFIER_WEBHOOK_URL="https://hooks.slack.com/services/XXXXX/XXXXX/XXXXX"
mix phx.server

2. ブラウザでアクセス

- http://localhost:4000/


-    /metrics で JSON データを確認可能

-    / で簡易ダッシュボード表示


3. Docker で実行

- イメージビルド

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

* * * * * /home/$USERNAME/monitoring-project/scripts/collect_metrics.sh >> /home/$USERNAME/monitoring-project/logs/metrics.log 2>&1

