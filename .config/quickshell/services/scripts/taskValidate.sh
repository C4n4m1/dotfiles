#!/bin/bash
# complete_todoist_task.sh

# Load token from config file
TOKEN_FILE="$HOME/.config/todoist/token"

if [ ! -f "$TOKEN_FILE" ]; then
    echo "Error: Token file not found at $TOKEN_FILE"
    exit 1
fi

TOKEN=$(cat "$TOKEN_FILE")
TASK_ID=$1

if [ -z "$TASK_ID" ]; then
    echo "Error: No task ID provided"
    echo "Usage: $0 TASK_ID"
    exit 1
fi

RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
    "https://api.todoist.com/rest/v1/tasks/$TASK_ID/close" \
    -H "Authorization: Bearer $TOKEN" \
    -H "X-Request-Id: $(uuidgen)")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)

if [ "$HTTP_CODE" -eq 204 ]; then
    echo "✓ Task $TASK_ID completed successfully"
    exit 0
else
    echo "✗ Failed to complete task $TASK_ID (HTTP $HTTP_CODE)"
    echo "$RESPONSE" | head -n -1
    exit 1
fi

# thanks to Claude Sonnet 4.5
