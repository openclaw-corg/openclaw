#!/bin/bash
# OpenClaw Backup Script
# Backs up source code and config to backup folder

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_BASE="/Users/admin/workspace/OPC/backup/openclaw-bk"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="$BACKUP_BASE/$TIMESTAMP"

echo "=== OpenClaw Backup ==="
echo "Timestamp: $TIMESTAMP"
echo "Backup directory: $BACKUP_DIR"

mkdir -p "$BACKUP_DIR"

# 1. Backup .env file
if [ -f "$SCRIPT_DIR/.env" ]; then
    echo "[1/2] Backing up .env..."
    cp "$SCRIPT_DIR/.env" "$BACKUP_DIR/env.backup"
else
    echo "[1/2] WARNING: .env file not found"
fi

# 2. Backup source code (exclude node_modules, dist, .git)
echo "[2/2] Backing up source code..."
tar -czf "$BACKUP_DIR/openclaw-src.tar.gz" \
    -C "$(dirname "$SCRIPT_DIR")" \
    --exclude="openclaw/node_modules" \
    --exclude="openclaw/dist" \
    --exclude="openclaw/dist-runtime" \
    --exclude="openclaw/.git" \
    openclaw

TOTAL_SIZE=$(du -sh "$BACKUP_DIR" | cut -f1)

echo ""
echo "=== Backup Complete ==="
echo "Location: $BACKUP_DIR"
echo "Total size: $TOTAL_SIZE"

# Cleanup old backups (keep last 5)
cd "$BACKUP_BASE"
ls -t | tail -n +6 | xargs -I {} rm -rf {} 2>/dev/null || true
echo "Done."
