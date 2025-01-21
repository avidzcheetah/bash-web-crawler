#!/bin/bash

# Function to fetch a webpage
fetch_webpage() {
    local url="$1"
    local html=$(curl -s -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36" "$url")
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
    local url="$2"
    local internal_domain=$(echo "$url" | awk -F/ '{print $3}')
    echo "Extracting First 10 Links with Classification:"
    echo "$html" | grep -oP '(?i)href="[^">]+"' | sed -E 's/href="([^"]+)"/\1/' | head -n 10 | while read -r link; do
        if [[ "$link" == *"$internal_domain"* ]]; then
            echo "- Internal link: $link"
        elif [[ "$link" =~ ^http://[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+ ]]; then
            echo "- Link to IP address (potentially risky): $link"
        else
            echo "- External link: $link"
        fi
    done
    echo
}

# Function to check vulnerabilities
check_vulnerabilities() {
    local html="$1"
    local url="$2"
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

    # Check for missing security headers
    local headers=$(curl -sI "$url")
    [[ "$headers" != *"Content-Security-Policy"* ]] && echo "- Missing Content-Security-Policy header"
    [[ "$headers" != *"X-Frame-Options"* ]] && echo "- Missing X-Frame-Options header"
    [[ "$headers" != *"Strict-Transport-Security"* ]] && echo "- Missing Strict-Transport-Security header"

    # Detect deprecated tags
    echo "$html" | grep -oP '(?i)<(marquee|blink)>' | sed 's/^/- Deprecated tag found: /'

    # Detect potential XSS vulnerabilities
    echo "$html" | grep -i -o '<script>.*</script>' | sed 's/^/- Inline script detected (possible XSS): /'
    echo "$html" | grep -i -o '<img[^>]*onerror=[^>]*>' | sed 's/^/- Potential XSS in img tag: /'

    # Detect open redirect vulnerabilities
    echo "$html" | grep -oP '(?i)(href|action)="[^"]+"' | grep -P '([?&](redirect|url|next|goto)=)' | sed -E 's/.*(href|action)="([^"]+)".*/- Potential open redirect link: \2/'
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

    # Validate URL format
    if ! [[ "$url" =~ ^https?://[^/]+ ]]; then
        echo "Invalid URL format. Please use http:// or https://"
        exit 1
    fi

    # Fetch the webpage
    html=$(fetch_webpage "$url")

    if [[ -z "$html" ]]; then
        echo "Failed to fetch the webpage."
        exit 1
    fi

    # Extract information
    extract_headings "$html"
    extract_paragraphs "$html"
    extract_links "$html" "$url"

    # Check vulnerabilities
    check_vulnerabilities "$html" "$url"
}

# Run the script
main
