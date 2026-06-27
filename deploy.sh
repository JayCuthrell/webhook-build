#!/bin/zsh

# 1. Define where you want the logs to be saved
LOG_FILE="/home/jay/github/webhook-build/deploy.log"

# 2. Automatically redirect ALL output and errors to the log file (append mode)
exec >> "$LOG_FILE" 2>&1

# 3. Stop the script immediately if any command fails
set -e

# Load Node v24.7.0 (Retained from your original script)
export PATH=/home/jay/.nvm/versions/node/v24.7.0/bin:$PATH

# Path to your repository
PROJECT_DIR="/home/jay/github/fudge-org-eleventy-excellent-4.3.3"

echo "========================================"
echo "--- Starting Build for fudge.org at $(date) ---"

cd $PROJECT_DIR || { echo "Directory not found"; exit 1; }

# 1. Get the latest content
echo "--> Pulling latest changes from GitHub..."
git pull origin main

# 2. Update dependencies
echo "--> Updating dependencies..."
npm install

# 3. Build the site
echo "--> Building site..."
time NODE_OPTIONS=--max-old-space-size=3072 npm run build

echo "--- Build finished successfully at $(date) ---"
echo "========================================"
