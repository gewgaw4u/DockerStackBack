#!/bin/bash

# Configuration Start
PARENT_DIR="/mnt/docker/stacks"    # set parent folder of your docker stacks
BACKUP_ROOT="/mnt/docker/backups"  # set backup location
COMPOSE_FILENAME="compose.yaml"         # Change to docker-compose.yml if needed
RETENTION_DAYS=30                       # Set how many days of "last-of-day" versions to keep
# Configirgation End ***DO NOT EDIT BELOW THIS LINE***
TIMESTAMP=$(date +"%Y-%m-%d_%H%M")
TODAY=$(date +"%Y-%m-%d")

# Initialize Dry Run flag
DRY_RUN=false
if [[ "$*" == *"--dry-run"* ]]; then
    DRY_RUN=true
    echo "--- DRY RUN MODE ENABLED: No changes will be made ---"
fi

# Wrapper Function for Actions
run_cmd() {
    if [ "$DRY_RUN" = true ]; then
        echo "[DRY-RUN] Would execute: $*"
    else
        "$@"
    fi
}

do_backup() {
    echo "Starting backup routine..."
    find "$PARENT_DIR" -type f -name ".tobackup" | while read -r marker; do
        CONTAINER_DIR=$(dirname "$marker")
        CONTAINER_NAME=$(basename "$CONTAINER_DIR")
        TARGET_BACKUP_DIR="$BACKUP_ROOT/$CONTAINER_NAME"

        if [ -f "$CONTAINER_DIR/$COMPOSE_FILENAME" ]; then
            run_cmd mkdir -p "$TARGET_BACKUP_DIR"

            # List of files to attempt to backup
            # Format: "Source_Filename|Target_Prefix"
            files_to_copy=("$COMPOSE_FILENAME|$COMPOSE_FILENAME" ".env|.env" "Dockerfile|Dockerfile")

            for entry in "${files_to_copy[@]}"; do
                src="${entry%|*}"
                prefix="${entry#*|}"

                if [ -f "$CONTAINER_DIR/$src" ]; then
                    run_cmd cp "$CONTAINER_DIR/$src" "$TARGET_BACKUP_DIR/${prefix}_$TIMESTAMP"
                    echo "Action: Backed up $src for $CONTAINER_NAME"
                fi
            done
        else
            echo "Warning: .tobackup found in $CONTAINER_NAME but $COMPOSE_FILENAME is missing."
        fi
    done
}

do_prune() {
    echo "Starting pruning routine (Retention: $RETENTION_DAYS days)..."
    find "$BACKUP_ROOT" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | while read -r TARGET_BACKUP_DIR; do

        # 1. Consolidate past days (Keep only the latest version per day)
		# Remove 'grep -v "$TODAY"' (below) so today's duplicates are handled too
        dates=$(ls "$TARGET_BACKUP_DIR"/*_* 2>/dev/null | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' | grep -v "$TODAY" | sort -u)

        for d in $dates; do
            # Process each prefix type
            for prefix in "$COMPOSE_FILENAME" ".env" "Dockerfile"; do
                files_for_day=$(ls "$TARGET_BACKUP_DIR"/${prefix}_"$d"_* 2>/dev/null | sort)
                last_file=$(echo "$files_for_day" | tail -n 1)

                for f in $files_for_day; do
                    if [ "$f" != "$last_file" ]; then
                        run_cmd rm "$f"
                    fi
                done
            done
        done

        # 2. Global Cleanup (Remove anything older than RETENTION_DAYS)
        if [ "$DRY_RUN" = true ]; then
            find "$TARGET_BACKUP_DIR" -type f -mtime +"$RETENTION_DAYS" -exec echo "[DRY-RUN] Deleting old file: {}" \;
        else
            find "$TARGET_BACKUP_DIR" -type f -mtime +"$RETENTION_DAYS" -delete
        fi
    done
    echo "Pruning finished."
}

# --- MANDATORY ROUTINE CHECK ---
case "$1" in
    backup) do_backup ;;
    prune)  do_prune ;;
    *)
        echo "Error: No valid subroutine provided."
        echo "Usage: $(basename "$0") {backup|prune} [--dry-run]"
        exit 1
        ;;
esac
