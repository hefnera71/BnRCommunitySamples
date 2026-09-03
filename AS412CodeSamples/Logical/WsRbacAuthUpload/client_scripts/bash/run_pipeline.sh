#!/bin/bash

# created by AI

# 1. Read input parameters ($1 = Base URI, $2 = Username, $3 = Password, $4 = File path)
BASE_URI="$1"
USERNAME="$2"
PASSWORD="$3"
FILE_PATH="$4"

# 2. Check if all four mandatory parameters were provided
if [ -z "$BASE_URI" ] || [ -z "$USERNAME" ] || [ -z "$PASSWORD" ] || [ -z "$FILE_PATH" ]; then
    echo "Error: Invalid parameters."
    echo "Usage: $0 \"[BASE_URI]\" \"[USERNAME]\" \"[PASSWORD]\" \"[FILE_PATH]\""
    echo "Example: $0 \"https://192.168.168.178\" \"User3\" \"87654321\" \"/tmp/testdata.txt\""
    exit 1
fi

# 3. Verify if the target file actually exists locally
if [ ! -f "$FILE_PATH" ]; then
    echo "Error: The file \"$FILE_PATH\" was not found."
    exit 1
fi

# 4. Remove trailing slash from Base URI if present to prevent double slashes
BASE_URI="${BASE_URI%/}"

# 5. Define full API endpoint URLs
AUTH_URL="$BASE_URI/authenticate.cgi"
UPLOAD_URL="$BASE_URI/uploader.cgi"

# 6. Generate a random number for the _ts parameter ($RANDOM is built-in in Bash)
TS_RANDOM=$RANDOM

echo "==================================================="
echo "1. AUTHENTICATION"
echo "==================================================="
# Execute curl and capture the raw response
response_auth=$(curl -sS -k -X POST -d "user=$USERNAME" -d "password=$PASSWORD" -d "_ts=$TS_RANDOM" -H "Content-Type: application/x-www-form-urlencoded" "$AUTH_URL" 2>/dev/null)
echo "Response: $response_auth"
echo ""

# 7. Extract UUID using PCRE regular expressions (looks for uuid:"...")
uuid=$(echo "$response_auth" | grep -oP 'uuid:"\K[^"\}]+')

# 8. Second Stage: Proceed with upload if UUID extraction succeeded
if [ -n "$uuid" ]; then
    echo "==================================================="
    echo "2. FILE UPLOAD"
    echo "==================================================="
    echo "Starting upload of: \"$FILE_PATH\"..."
    
    response_upload=$(curl -sS -k -X POST -F "filename=@$FILE_PATH" -H "Content-Type: multipart/form-data" "$UPLOAD_URL?do_upload=true&uuid=$uuid" 2>/dev/null)
    echo "Response: $response_upload"
    echo ""
    
    echo "==================================================="
    echo "3. TERMINATE CONNECTION"
    echo "==================================================="
    echo "Closing session..."
    
    response_end=$(curl -sS -k -X GET "$UPLOAD_URL?end_upload=true&uuid=$uuid" 2>/dev/null)
    echo "Response: $response_end"
    echo "==================================================="
else
    echo "Error: Could not extract UUID. Login failed?"
    exit 1
fi

exit 0
