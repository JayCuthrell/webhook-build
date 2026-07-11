#!/bin/zsh

# 1. Define log file location inside your verified webhook directory
LOG_FILE="/home/jay/github/webhook-build/deploy.log"

# 2. Automatically redirect ALL output and errors to the log file (append mode)
exec >> "$LOG_FILE" 2>&1

# 3. Stop immediately if any critical command exits with an error status
set -e

# 4. Load Node v24.7.0 explicitly from your NVM installation
export PATH=/home/jay/.nvm/versions/node/v24.7.0/bin:$PATH

echo "========================================"
echo "--- Deployment triggered at $(date) ---"

# =================================================================
# THE "KILL & REPLACE" DEBOUNCE BLOCK
# Prevents server CPU load spikes from rapid sequential commits
# =================================================================
PID_FILE="/tmp/fudge_deploy.pid"

if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE")
    if ps -p "$OLD_PID" > /dev/null 2>&1; then
        echo "--> Rapid commit detected! Terminating outdated build (PID: $OLD_PID)..."
        kill -9 "$OLD_PID" 2>/dev/null || true
    fi
fi

# Record the current script's Process ID for the next incoming webhook
echo $$ > "$PID_FILE"

# Terminate any orphaned Eleventy or Pagefind child processes from aborted builds
echo "--> Cleaning up background CPU tasks..."
pkill -f "build:11ty" 2>/dev/null || true
pkill -f "pagefind --site" 2>/dev/null || true
pkill -f "npm run build" 2>/dev/null || true

# Give the Linux kernel 2 seconds to release file locks and reclaim CPU/RAM
sleep 2
# =================================================================

# Navigate to your live static site directory
PROJECT_DIR="/home/jay/github/fudge-org-eleventy-excellent-4.3.3"
cd $PROJECT_DIR || { echo "CRITICAL ERROR: Directory not found"; exit 1; }

# Force local repository to become a 1:1 mirror of GitHub (prevents merge errors)
echo "--> Forcing exact sync with GitHub main branch..."
git fetch origin main
git reset --hard origin/main

# Install dependencies safely
echo "--> Updating dependencies..."
npm install

# Build the Eleventy site and generate Pagefind search indexes with expanded memory
echo "--> Building site..."
time NODE_OPTIONS=--max-old-space-size=3072 npm run build

echo "--- Build finished successfully at $(date) ---"
echo "========================================"
