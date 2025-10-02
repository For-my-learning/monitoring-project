#!/usr/bin/env bash
set -euo pipefail




ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUTDIR="$ROOT/$USER/data"
mkdir -p "$OUTDIR"

# --- CPU usage (simple sample of /proc/stat)
read -r _ user1 nice1 system1 idle1 iowait1 irq1 soft1 steal1 < <(awk '/^cpu /{print $1,$2,$3,$4,$5,$6,$7,$8,$9}' /proc/stat)
total1=$((user1 + nice1 + system1 + idle1 + iowait1 + irq1 + soft1 + steal1))
sleep 0.2
read -r _ user2 nice2 system2 idle2 iowait2 irq2 soft2 steal2 < <(awk '/^cpu /{print $1,$2,$3,$4,$5,$6,$7,$8,$9}' /proc/stat)
total2=$((user2 + nice2 + system2 + idle2 + iowait2 + irq2 + soft2 + steal2))
diff_total=$((total2 - total1))
diff_idle=$((idle2 - idle1))
if [ "$diff_total" -eq 0 ]; then
  cpu_usage=0.0
else
  cpu_usage=$(awk "BEGIN {printf \"%.1f\", 100*($diff_total - $diff_idle)/$diff_total}")
fi

# --- Memory usage (percent)
mem_total_kb=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
mem_avail_kb=$(awk '/MemAvailable/ {print $2}' /proc/meminfo)
if [ -z "$mem_total_kb" ] || [ "$mem_total_kb" -eq 0 ]; then
  mem_usage=0.0
else
  mem_usage=$(awk "BEGIN {printf \"%.1f\", 100*($mem_total_kb - $mem_avail_kb)/$mem_total_kb}")
fi

# --- Disk usage for root (/)
disk_usage=$(df -P / | awk 'NR==2 {gsub(/%/,"",$5); print $5+0}')

# --- timestamp
timestamp=$(date  +"%Y-%m-%d %H:%M:%S")

# --- write metrics json
cat > "$OUTDIR/metrics.json" <<EOF
{
  "cpu": $cpu_usage,
  "mem": $mem_usage,
  "disk": $disk_usage,
  "timestamp": "$timestamp"
}
EOF

# --- collect recent error logs
ERRFILE="$OUTDIR/errors.log"
# Prefer journalctl when allowed
if command -v journalctl >/dev/null 2>&1 && journalctl --no-pager -n0 >/dev/null 2>&1; then
  # request last 50 err messages (may need sudo depending on system)
  journalctl -p err -n 50 --no-pager > "$ERRFILE" 2>/dev/null || sudo journalctl -p err -n 50 --no-pager > "$ERRFILE" 2>/dev/null || true
else
  # fallback: try /var/log/syslog or /var/log/messages
  if [ -f /var/log/syslog ]; then
    tail -n 50 /var/log/syslog > "$ERRFILE" || true
  elif [ -f /var/log/messages ]; then
    tail -n 50 /var/log/messages > "$ERRFILE" || true
  else
    echo "" > "$ERRFILE"
  fi
fi

