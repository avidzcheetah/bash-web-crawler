#!/bin/bash

# ==============================================================================
# ░▒█▀▀▄░█▀▀▄░█▀▀▄░█░░░█░█░░█▀▀░█▀▀▄
# ░▒█░░░░█▄▄▀░█▄▄█░▀▄█▄▀░█░░█▀▀░█▄▄▀
# ░▒█▄▄▀░▀░▀▀░▀░░▀░░▀░▀░░▀▀░▀▀▀░▀░▀▀
#                     by 𝘈𝘷𝘪𝘥𝘻 (Advanced AI Version)
# ==============================================================================
# Advanced Bash Wrapper for AI-Powered Web Vulnerability Scanner
# ==============================================================================

# Colors for UI
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
MAX_PAGES=10
OUTPUT_FILE="scan_report"
VERBOSE=0

# Help function
show_help() {
    echo -e "${BLUE}Usage: $0 [options] <URL>${NC}"
    echo ""
    echo "Options:"
    echo "  -p, --pages <num>    Maximum pages to crawl (default: 10)"
    echo "  -o, --output <file>  Output filename without extension (default: scan_report)"
    echo "  -v, --verbose        Enable verbose logging"
    echo "  -h, --help           Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 https://example.com"
    echo "  $0 -p 50 -o my_scan https://example.com"
}

# Progress bar function
show_progress() {
    local duration=$1
    local prefix=$2
    local col=50
    echo -ne "$prefix "
    for ((i=1; i<=col; i++)); do
        echo -ne "░"
        sleep 0.05
    done
    echo -e " [DONE]"
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -p|--pages)
            MAX_PAGES="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        -v|--verbose)
            VERBOSE=1
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        http*)
            TARGET_URL="$1"
            shift
            ;;
        *)
            echo -e "${RED}Error: Unknown argument $1${NC}"
            show_help
            exit 1
            ;;
    esac
done

if [[ -z "$TARGET_URL" ]]; then
    echo -e "${RED}Error: Target URL is required.${NC}"
    show_help
    exit 1
fi

echo -e "${BLUE}"
echo "    ░▒█▀▀▄░█▀▀▄░█▀▀▄░█░░░█░█░░█▀▀░█▀▀▄"
echo "    ░▒█░░░░█▄▄▀░█▄▄█░▀▄█▄▀░█░░█▀▀░█▄▄▀"
echo "    ░▒█▄▄▀░▀░▀▀░▀░░▀░░▀░▀░░▀▀░▀▀▀░▀░▀▀ v2.0"
echo "                        by 𝘈𝘷𝘪𝘥𝘻"
echo -e "${NC}"

# Path resolution for native Python on Git Bash (Windows)
if command -v pwd >/dev/null && pwd -W >/dev/null 2>&1; then
    export PLAYWRIGHT_BROWSERS_PATH="$(pwd -W)/pw-browsers"
else
    export PLAYWRIGHT_BROWSERS_PATH="$PWD/pw-browsers"
fi

# Check for Python and Virtual Environment
if [[ ! -d "venv" ]]; then
    echo -e "${YELLOW}[!] Virtual environment not found. Initializing setup...${NC}"
    show_progress 2 "Setting up environment"
    python -m venv venv
    source venv/Scripts/activate || source venv/bin/activate
    pip install -r requirements.txt &> /dev/null
    
    echo -e "\n${YELLOW}[!] Installing Playwright browsers locally... This may take a moment.${NC}"
    playwright install chromium
else
    source venv/Scripts/activate || source venv/bin/activate
    # Dynamic check for playwright browsers
    if [[ ! -d "$PLAYWRIGHT_BROWSERS_PATH" ]]; then
         echo -e "${YELLOW}[!] Playwright browsers might be missing. Verifying...${NC}"
         playwright install chromium
    fi
fi

# Check for .env file
if [[ ! -f ".env" ]]; then
    echo -e "${YELLOW}[!] Warning: .env file missing. AI features may be disabled.${NC}"
fi

# Run the scanner
echo -e "${GREEN}[*] Initializing deep scan on: ${TARGET_URL}${NC}"
echo -e "${GREEN}[*] Max Pages: ${MAX_PAGES} | Output: ${OUTPUT_FILE}${NC}"
echo ""

# Use python to run the main script
PYTHONPATH=. python main.py "$TARGET_URL" --max-pages "$MAX_PAGES" --output "$OUTPUT_FILE"

if [[ $? -eq 0 ]]; then
    echo -e "\n${GREEN}[+] Scan completed successfully!${NC}"
    echo -e "${BLUE}[i] Reports available at:${NC}"
    echo -e "    - ${OUTPUT_FILE}.json"
    echo -e "    - ${OUTPUT_FILE}.md"
else
    echo -e "\n${RED}[!] Scan failed or was interrupted.${NC}"
    exit 1
fi
