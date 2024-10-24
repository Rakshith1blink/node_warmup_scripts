#!/bin/bash

# URL to request
url=$1
header_value=$2
echo ${url} -- ${header_value}

# Header key and value
header_key="s-id"

# Send the request using curl and store the response
response=$(curl -s -H "$header_key: $header_value" "$url")

echo ${response}

# Check if response is not empty
if [[ -n "$response" ]]; then
    # Extract domains using jq, filter out null values
    domains=$(echo "$response" | jq -r '.urls[] | select(.domain != null) | .domain')

    # Loop through each domain
    while IFS= read -r domain; do
        # Remove the "http://" or "https://" prefix if present
        domain=$(echo "$domain" | sed 's~http[s]*://~~')

        # Check if the domain is already in /etc/hosts
        if ! grep -q "$domain" /etc/hosts; then
            # Append the domain to /etc/hosts
            echo "127.0.0.1 $domain" | sudo tee -a /etc/hosts > /dev/null
        else
            echo "$domain is already in /etc/hosts"
        fi
    done <<< "$domains"
else
    echo "Error: Empty response from the server."
fi

# Check if response is not empty
if [[ -n "$response" ]]; then
    # Extract partner and url using jq
    partners_urls=$(echo "$response" | jq -r '.urls[] | "\(.domain):5001\(.url)"')

    i=0
    while [ $i -lt 75 ]; do
        # Loop through each URL and curl it
        while IFS= read -r url; do
            echo "URL: $url"
            echo "---------------------------------------"
            curl_result=$(curl -I "$url")
            echo "$curl_result"
            echo "---------------------------------------"
            echo  # Optional: Print a newline between each curl request
        done <<< "$partners_urls"
        i=$((i+1))
        echo "--------------done----------"
    done
else
    echo "Error: Empty response from the server."
fi

