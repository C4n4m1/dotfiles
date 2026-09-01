#!/bin/bash
TOKEN_FILE="$HOME/.config/todoist/token"
TOKEN=$(cat "$TOKEN_FILE")

# Get all active tasks
curl -s "https://api.todoist.com/rest/v1/tasks" \
  -H "Authorization: Bearer $TOKEN"

# # Get today's tasks
# curl -s "https://api.todoist.com/rest/v1/tasks?filter=today" \
#   -H "Authorization: Bearer $TOKEN"

# # Get tasks due in the next 7 days
# curl -s "https://api.todoist.com/rest/v1/tasks?filter=7%20days" \
#   -H "Authorization: Bearer $TOKEN"
