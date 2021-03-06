#!/usr/bin/env bash

THEME_NAME="$1"
URL="$2"
KEY="$3"

# Split the key into ID and SECRET
TMPIFS=$IFS
IFS=':' read ID SECRET <<< "$KEY"
IFS=$TMPIFS

# Prepare header and payload
NOW=$(date +'%s')
FIVE_MINS=$(($NOW + 300))
HEADER="{\"alg\": \"HS256\",\"typ\": \"JWT\", \"kid\": \"$ID\"}"
PAYLOAD="{\"iat\":$NOW,\"exp\":$FIVE_MINS,\"aud\": \"/v3/admin/\"}"

# Helper function for perfoming base64 URL encoding
base64_url_encode() {
    declare input=${1:-$(</dev/stdin)}
    # Use `tr` to URL encode the output from base64.
    printf '%s' "${input}" | base64 | tr -d '=' | tr '+' '-' |  tr '/' '_' | tr -d '\n'
}

# Prepare the token body
header_base64=$(base64_url_encode "$HEADER")
payload_base64=$(base64_url_encode "$PAYLOAD")

header_payload="${header_base64}.${payload_base64}"

# Create the signature
signature=$(printf '%s' "${header_payload}" | openssl dgst -binary -sha256 -mac HMAC -macopt hexkey:$SECRET | base64_url_encode)

# Concat payload and signature into a valid JWT token
TOKEN="${header_payload}.${signature}"

VERSION="$(date "+%Y%m%d")-$(echo "${CIRCLE_SHA1}" | cut -c "1-7")"

# Push archive
curl -H "Authorization: Ghost $TOKEN" \
-F "file=@${THEME_NAME}-${VERSION}.zip;type=application/zip" \
${URL}/ghost/api/v3/admin/themes/upload/

# Activate new theme
curl -X PUT -H "Authorization: Ghost $TOKEN" \
${URL}/ghost/api/v3/admin/themes/${THEME_NAME}-${VERSION}/activate/
