# Monitoring Project 

## 概要
Linux サーバの CPU、メモリ、ディスク使用量、最新エラー情報を収集し、Web API で確認できるとともに、閾値を超えた場合に Slack に通知するシステム。

- Bash スクリプトでサーバメトリクス収集
- Phoenix アプリで `/metrics` API と簡易ダッシュボード表示
- Slack Webhook による閾値通知
- Docker 化でどこでも同じ環境で実行可能

- ホスト LinuxのBashスクリプト ->  JSON生成
- Dockerコンテナ内のElixir読み込み(starting phx.server)
- 閾値を超えた場合に -> Slack通知 & ダッシュボード表示

---

---

## ローカル実行

1. metrics collector を手動で動かす（または cron）

```bash
bash scripts/collect_metrics.sh
```

2 . Phoenix サーバを起動

```bash
cd monitoring
mix deps.get
export NOTIFIER_WEBHOOK_URL=""https://hooks.slack.com/services/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

mix phx.server
```

ブラウザでアクセス

- http://localhost:4000/

-    /metrics で JSON データを確認可能

-    / で簡易ダッシュボード表示


3. Docker 実行

イメージビルド
```bash
cd monitoring
docker build -t monitoring-app .
```

コンテナ起動（データディレクトリをマウント）
```bash
docker run -p 4000:4000 \
  -v ~/monitoring-project/data:/app/../data \
  -e NOTIFIER_WEBHOOK_URL="https://hooks.slack.com/services/XXXXX/XXXXX/XXXXX" \
  monitoring-app
```

- ブラウザで http://localhost:4000/ にアクセス可能

- metrics.json はホスト側に保存され、リアルタイムに反映

4. Cron で定期収集（推奨）

毎分 metrics.json を更新する例：

```bash
* * * * * /home/$USERNAME/monitoring-project/scripts/collect_metrics.sh >> /home/$USERNAME/monitoring-project/logs/metrics.log 2>&1
```
