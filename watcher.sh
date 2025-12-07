#!/bin/bash

# Configuration
FILE_PATTERN_TO_WATCH="/home/*/public_html/deploy"
LOG_FILE_PATH="storage/logs/deploy.log"  # Relative to deploy.sh location
PERMISSION_UPDATE_PATH="public"           # Relative to deploy.sh location

echo "Global Build Watcher started at $(date)"

while true; do
    # Detect deploy files under any home folder
    for DEPLOY_FILE in $FILE_PATTERN_TO_WATCH; do
        
        [ -e "$DEPLOY_FILE" ] || continue

        ACCOUNT_DIR=$(echo "$DEPLOY_FILE" | cut -d'/' -f3)
        PROJECT_DIR="/home/$ACCOUNT_DIR/public_html"
        
        # Check if deploy.sh exists before doing anything
        if [ ! -f "$PROJECT_DIR/deploy.sh" ]; then
            rm -f "$DEPLOY_FILE"
            continue
        fi

        LOG_FILE="$PROJECT_DIR/$LOG_FILE_PATH"
        LOG_DIR=$(dirname "$LOG_FILE")
        PERMISSION_DIR="$PROJECT_DIR/$PERMISSION_UPDATE_PATH"

        # Real Linux user owner of the home folder
        REAL_USER=$(stat -c "%U" "/home/$ACCOUNT_DIR")

        mkdir -p "$LOG_DIR"

        echo "" >> "$LOG_FILE"
        echo "========================================" >> "$LOG_FILE"
        echo "Deploy triggered for account folder: $ACCOUNT_DIR (user: $REAL_USER) at $(date)" >> "$LOG_FILE"
        echo "========================================" >> "$LOG_FILE"

        cd "$PROJECT_DIR" || {
            echo "ERROR: Cannot cd into $PROJECT_DIR" >> "$LOG_FILE"
            rm -f "$DEPLOY_FILE"
            continue
        }

        # Execute deploy.sh script with username as argument
        ./deploy.sh "$REAL_USER" >> "$LOG_FILE" 2>&1
        DEPLOY_EXIT=$?

        # Fix permissions for specified folder
        if [ -d "$PERMISSION_DIR" ]; then
            chown -R "$REAL_USER":"$REAL_USER" "$PERMISSION_DIR"
        fi

        if [ $DEPLOY_EXIT -eq 0 ]; then
            echo "Deploy completed successfully at $(date)" >> "$LOG_FILE"
        else
            echo "Deploy FAILED at $(date)" >> "$LOG_FILE"
        fi

        rm -f "$DEPLOY_FILE"
        echo "Trigger file deleted" >> "$LOG_FILE"
    done

    sleep 2
done