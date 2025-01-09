#!/bin/bash

# Function to fetch a webpage
fetch_webpage() {
    local url="$1"
    local html=$(curl -s "$url")
    echo "$html"
}

# Function to extract headings
extract_headings() {
    local html="$1"
    echo "Extracting Headings:"
    echo "$html" | grep -oP '(?i)<h[1-6][^>]*>.*?</h[1-6]>' | sed -E 's/<[^>]+>//g' | awk '{print "- " $0}'
    echo
}

# Function to extract paragraphs
extract_paragraphs() {
    local html="$1"
    echo "Extracting First 5 Paragraphs:"
    echo "$html" | grep -oP '(?i)<p[^>]*>.*?</p>' | sed -E 's/<[^>]+>//g' | head -n 5 | awk '{print "- " $0}'
    echo
}

# Function to extract links
extract_links() {
    local html="$1"
    echo "Extracting First 10 Links:"
    echo "$html" | grep -oP '(?i)href="[^"]+"' | sed -E 's/href=//g; s/"//g' | head -n 10 | awk '{print "- " $0}'
    echo
}

# Function to check vulnerabilities
check_vulnerabilities() {
    local html="$1"
    echo "Checking for Potential Vulnerabilities:"

    # Check for insecure forms
    echo "$html" | grep -oP '(?i)<form[^>]*action="[^"]+"' | grep -v "https://" | sed -E 's/.*action="([^"]+)".*/- Form with insecure action: \1/'

    # Check for external scripts
    echo "$html" | grep -oP '(?i)<script[^>]*src="[^"]+"' | grep -v "$(echo "$url" | awk -F/ '{print $3}')" | sed -E 's/.*src="([^"]+)".*/- External script loaded: \1/'

    # Check if HTTPS is used
    if ! echo "$url" | grep -q "https://"; then
        echo "- The webpage does not use HTTPS."
    fi

    # Check for insecure links
    echo "$html" | grep -oP '(?i)href="http://[^"]+"' | sed -E 's/href="//g; s/"//g' | awk '{print "- Insecure link found: " $0}'

    echo
}

# Main function
main() {
    echo "
            ░▒█▀▀▄░█▀▀▄░█▀▀▄░█░░░█░█░░█▀▀░█▀▀▄
            ░▒█░░░░█▄▄▀░█▄▄█░▀▄█▄▀░█░░█▀▀░█▄▄▀
            ░▒█▄▄▀░▀░▀▀░▀░░▀░░▀░▀░░▀▀░▀▀▀░▀░▀▀
                                by 𝘈𝘷𝘪𝘥𝘻
    https://github.com/avidzcheetah
    "


    # Input URL
    read -p "Enter the URL of the webpage: " url

    # Fetch the webpage
    html=$(fetch_webpage "$url")

    if [[ -z "$html" ]]; then
        echo "Failed to fetch the webpage."
        exit 1
    fi

    # Extract information
    extract_headings "$html"
    extract_paragraphs "$html"
    extract_links "$html"

    # Check vulnerabilities
    check_vulnerabilities "$html"
}

# Run the script
main
