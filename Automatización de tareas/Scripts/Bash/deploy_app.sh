#!/bin/bash

# Simple Deployment Script in Bash
# Usage: ./deploy_app.sh

REPO_PATH="/home/user/projects/webapp"
SERVICE_NAME="nginx"
LOG_FILE="./deploy.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
    echo "$1"
}

log "Starting deployment..."

if [ ! -d "$REPO_PATH" ]; then
    log "Error: Repository path $REPO_PATH does not exist."
    exit 1
fi

cd "$REPO_PATH" || exit

log "Pulling latest changes..."
# git pull >> "$LOG_FILE" 2>&1

log "Installing dependencies..."
# npm install >> "$LOG_FILE" 2>&1

log "Restarting service $SERVICE_NAME..."
# sudo systemctl restart "$SERVICE_NAME"

log "Deployment finished."
