#!/bin/bash

TOKEN_FILE="$HOME/.config/quickshell/services/scripts/token.json"

# Read tokens from file
ACCESS_TOKEN=$(jq -r '.access_token' "$TOKEN_FILE")
REFRESH_TOKEN=$(jq -r '.refresh_token' "$TOKEN_FILE")
CLIENT_ID=$(jq -r '.client_id' "$TOKEN_FILE")
CLIENT_SECRET=$(jq -r '.client_secret' "$TOKEN_FILE")

# to get calendar list
# curl -s "https://www.googleapis.com/calendar/v3/users/me/calendarList" \
        # -H "Authorization: Bearer $(jq -r '.access_token' token.json)" | jq '.items[] | {id: .id, summary: .summary, primary: .primary}'
CALENDAR_IDS=(
    "hcanami@gmail.com"
    "b82e4bf2ceb2c9a509e2c82ff25e25d71f20ce6e5ab31b4b989924a0b1b13f30@group.calendar.google.com"
)

# Function to refresh token if needed
refresh_token() {
    RESPONSE=$(curl -s -X POST https://oauth2.googleapis.com/token \
        -d "client_id=$CLIENT_ID" \
        -d "client_secret=$CLIENT_SECRET" \
        -d "refresh_token=$REFRESH_TOKEN" \
        -d "grant_type=refresh_token")

    NEW_ACCESS_TOKEN=$(echo "$RESPONSE" | jq -r '.access_token')

    # Update token file
    if   [ -z "$NEW_ACCESS_TOKEN" ]; then
        echo "acces token empty";
    else
        jq ".access_token = \"$NEW_ACCESS_TOKEN\"" "$TOKEN_FILE" > "$TOKEN_FILE.tmp" && mv "$TOKEN_FILE.tmp" "$TOKEN_FILE"
    fi

    echo "$NEW_ACCESS_TOKEN"
}

# Fetch events from a calendar
fetch_calendar_events() {
    local token=$1
    local calendar_id=$2
    local time_min=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    # URL encode the calendar ID
    # local encoded_id=$(echo "$calendar_id" | jq -sRr @uri)

    curl -s "https://www.googleapis.com/calendar/v3/calendars/$calendar_id/events?maxResults=10&orderBy=startTime&singleEvents=true&timeMin=$time_min" \
        -H "Authorization: Bearer $token" \
        -H "Accept: application/json"
}


echo '['
# Fetch events from all calendars and combine
last_index=$((${#CALENDAR_IDS[@]} - 1))

for i in "${!CALENDAR_IDS[@]}"; do
    CALENDAR_ID=${CALENDAR_IDS[$i]}
    EVENTS=$(fetch_calendar_events "$ACCESS_TOKEN" "$CALENDAR_ID")

    if echo "$EVENTS" | jq -e '.error.code == 401' > /dev/null 2>&1; then
        ACCESS_TOKEN=$(refresh_token)
        EVENTS=$(fetch_calendar_events "$ACCESS_TOKEN" "$CALENDAR_ID")
    fi

    echo "$EVENTS"

    # Add a comma unless it's the last element
    if [[ $i -lt $last_index ]]; then
        echo ','
    fi
done
echo ']'
