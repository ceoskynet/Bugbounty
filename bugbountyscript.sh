#!/bin/bash

# Global Variables
TARGET=$1
OUTPUT_DIR="results"
TOOLS_DIR="$HOME/tools"
VENV_DIR="$HOME/bugbounty_venv"

# Colors for visibility
GREEN="\033[0;32m"
CYAN="\033[0;36m"
RED="\033[0;31m"
RESET="\033[0m"

# Function to install tools in a Python virtual environment
setup_venv() {
    echo -e "${CYAN}[*] Setting up Python virtual environment...${RESET}"
    python3 -m venv $VENV_DIR
    source $VENV_DIR/bin/activate

    echo -e "${CYAN}[*] Installing Python-based tools in the virtual environment...${RESET}"
    pip install --upgrade pip
    pip install truffleHog graphqlmap XXEinjector
    
    echo -e "${GREEN}[+] Python tools installed in the virtual environment.${RESET}"
    deactivate
}

# Function to install system-based tools
install_tools() {
    echo -e "${CYAN}[*] Installing required tools...${RESET}"

    sudo apt update && sudo apt install -y \
        nmap masscan rustscan \
        amass ffuf gobuster httpx subjack \
        nuclei sqlmap xsstrike waybackurls gau \
        jq curl git golang
    
    # Install Go-based tools
    go install github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest
    go install github.com/projectdiscovery/katana/cmd/katana@latest
    go install github.com/projectdiscovery/ghauri/v2/cmd/ghauri@latest
    go install github.com/projectdiscovery/httpx/cmd/httpx@latest

    echo -e "${GREEN}[+] Tools installed successfully.${RESET}"
}

# Create output directory
setup_directories() {
    echo -e "${CYAN}[*] Setting up output directories...${RESET}"
    mkdir -p "$OUTPUT_DIR"
}

# Stealthy port scanning
perform_port_scan() {
    echo -e "${CYAN}[*] Performing fast and stealthy port scans...${RESET}"

    echo -e "${CYAN}[*] Nmap Scan...${RESET}"
    nmap -T4 -Pn -sC -sV -oN "$OUTPUT_DIR/nmap_scan.txt" $TARGET

    echo -e "${CYAN}[*] Masscan Scan...${RESET}"
    sudo masscan $TARGET -p1-65535 --rate=1000 -oX "$OUTPUT_DIR/masscan_scan.xml"

    echo -e "${CYAN}[*] RustScan...${RESET}"
    rustscan -a $TARGET --ulimit 5000 -- -sV -oN "$OUTPUT_DIR/rustscan.txt"
}

# Subdomain enumeration
enumerate_subdomains() {
    echo -e "${CYAN}[*] Enumerating subdomains...${RESET}"

    echo -e "${CYAN}[*] Using Amass...${RESET}"
    amass enum -d $TARGET -o "$OUTPUT_DIR/amass_subdomains.txt"

    echo -e "${CYAN}[*] Using Gobuster...${RESET}"
    gobuster dns -d $TARGET -w /usr/share/wordlists/dns/subdomains-top1million-110000.txt -o "$OUTPUT_DIR/gobuster_subdomains.txt"

    echo -e "${CYAN}[*] Filtering live subdomains with HTTPx...${RESET}"
    cat "$OUTPUT_DIR/amass_subdomains.txt" "$OUTPUT_DIR/gobuster_subdomains.txt" | sort -u | httpx -silent -o "$OUTPUT_DIR/live_subdomains.txt"
}

# Subdomain takeover check
check_subdomain_takeover() {
    echo -e "${CYAN}[*] Checking for subdomain takeover...${RESET}"
    subjack -w "$OUTPUT_DIR/live_subdomains.txt" -o "$OUTPUT_DIR/subjack_results.txt" -ssl
}

# Scraping Wayback Machine and grabbing URLs
scrape_waybackurls() {
    echo -e "${CYAN}[*] Scraping Wayback Machine and GAU for URLs...${RESET}"
    waybackurls $TARGET > "$OUTPUT_DIR/waybackurls.txt"
    gau $TARGET > "$OUTPUT_DIR/gau_urls.txt"
    cat "$OUTPUT_DIR/waybackurls.txt" "$OUTPUT_DIR/gau_urls.txt" | sort -u > "$OUTPUT_DIR/combined_urls.txt"
    grep -E "\.php|\.env|\.json|\.js|\.config" "$OUTPUT_DIR/combined_urls.txt" > "$OUTPUT_DIR/sensitive_files.txt"
}

# Vulnerability scanning
perform_vulnerability_scan() {
    echo -e "${CYAN}[*] Running vulnerability scanners...${RESET}"

    echo -e "${CYAN}[*] Using Nuclei...${RESET}"
    nuclei -u $TARGET -o "$OUTPUT_DIR/nuclei_results.txt"

    echo -e "${CYAN}[*] Using Katana...${RESET}"
    katana -u $TARGET -o "$OUTPUT_DIR/katana_results.txt"

    echo -e "${CYAN}[*] Using Ghauri for SQL injection...${RESET}"
    ghauri -u $TARGET -o "$OUTPUT_DIR/ghauri_results.txt"

    echo -e "${CYAN}[*] Testing for XSS with XSStrike...${RESET}"
    xsstrike -u $TARGET > "$OUTPUT_DIR/xsstrike_results.txt"

    echo -e "${CYAN}[*] Testing for open redirects...${RESET}"
    openredirectx $TARGET > "$OUTPUT_DIR/open_redirects.txt"

    echo -e "${CYAN}[*] Mapping GraphQL APIs...${RESET}"
    source $VENV_DIR/bin/activate
    graphqlmap -u $TARGET > "$OUTPUT_DIR/graphqlmap_results.txt"
    deactivate

    echo -e "${CYAN}[*] Checking for XXE injection vulnerabilities...${RESET}"
    XXEinjector -u $TARGET > "$OUTPUT_DIR/xxe_results.txt"
}

# Fuzzing
perform_fuzzing() {
    echo -e "${CYAN}[*] Performing fuzzing...${RESET}"
    ffuf -u $TARGET/FUZZ -w /usr/share/wordlists/dirb/common.txt -o "$OUTPUT_DIR/ffuf_results.txt"
}

# Sensitive information discovery
discover_sensitive_info() {
    echo -e "${CYAN}[*] Searching for sensitive information...${RESET}"
    
    echo -e "${CYAN}[*] Using TruffleHog...${RESET}"
    source $VENV_DIR/bin/activate
    trufflehog git-url $TARGET > "$OUTPUT_DIR/trufflehog_results.txt"
    deactivate

    echo -e "${CYAN}[*] Performing Google Dorking...${RESET}"
    echo "site:$TARGET inurl:admin" >> "$OUTPUT_DIR/google_dorks.txt"
    echo "site:$TARGET filetype:env" >> "$OUTPUT_DIR/google_dorks.txt"
}
 
# Main Function
main() {
    if [ -z "$TARGET" ]; then
        echo -e "${RED}[!] Usage: $0 <target>${RESET}"
        exit 1
    fi

    install_tools
    setup_venv
    setup_directories
    perform_port_scan
    enumerate_subdomains
    check_subdomain_takeover
    scrape_waybackurls
    perform_vulnerability_scan
    perform_fuzzing
    discover_sensitive_info

    echo -e "${GREEN}[+] Recon and scanning completed! Results saved in $OUTPUT_DIR.${RESET}"
}

main
