# Bug Bounty Automation Script

## Overview

`bugbountyscript.sh` is an all-in-one Bash script designed to automate various tasks in bug bounty hunting and penetration testing. This script integrates several industry-standard tools to simplify reconnaissance, subdomain enumeration, vulnerability scanning, fuzzing, and sensitive information discovery for a target website.

---

## Features

The script automates the following tasks:
- **Port Scanning**:
  - Fast and stealthy scans using `Nmap`, `Masscan`, and `RustScan`.
- **Subdomain Enumeration**:
  - Subdomain discovery using `Amass`, `Gobuster`.
  - Filtering live subdomains with `HTTPx`.
  - Detecting subdomain takeover vulnerabilities with `Subjack`.
- **Web Scraping & Sensitive File Discovery**:
  - Scraping URLs from `Wayback Machine` and `GAU`.
  - Identifying sensitive files (e.g., `.env`, `.json`, `.js`, `.php`).
- **Fuzzing**:
  - Directory fuzzing with `FFUF` and optional manual exploration in `BurpSuite`.
- **Vulnerability Scanning**:
  - Scanning for vulnerabilities using `Nuclei`, `Katana`, `SQLMap`, `XSStrike`, `OpenRedirectX`, `GraphQLMap`, and `XXEInjector`.
- **Sensitive Information Discovery**:
  - Searching for exposed secrets in repositories with `TruffleHog`.
  - Generating Google Dork queries for manual exploration.
- **Customizable Python Virtual Environment (venv)**:
  - Python tools (e.g., `TruffleHog`, `GraphQLMap`, `XXEInjector`) are installed in an isolated Python virtual environment.

---

## Prerequisites

### **System Requirements**
- Linux-based OS (e.g., Ubuntu, Kali Linux, Parrot OS).
- Bash shell.
- Python 3.6+ installed.

### **Tools Required**
`bugbountyscript.sh` installs the following tools automatically if not already present:
- **System-based tools**: 
  - `nmap`, `masscan`, `rustscan`, `amass`, `ffuf`, `gobuster`, `httpx`, `subjack`, `nuclei`, `katana`, `gau`, `waybackurls`.
- **Python-based tools** (installed in a virtual environment):
  - `TruffleHog`, `GraphQLMap`, `XXEInjector`.

---

## Installation

### 1. Clone the Repository
```bash
git clone https://github.com/your-username/bug-bounty-automation.git
cd bug-bounty-automation



## Make the Script Executable
bash
chmod +x bugbountyscript.sh

Run the Script
./bugbountyscript.sh <target>

./bugbountyscript.sh <target>
Replace <target> with the domain of the target website you want to scan.
Example:
bash
Copy
Edit
./bugbountyscript.sh example.com
Output
All results will be saved in a directory named results in the current working directory.
The results are categorized into different files, such as:
nmap_scan.txt: Nmap scan results.
live_subdomains.txt: Live subdomains detected.
nuclei_results.txt: Vulnerability scan results from Nuclei.
sensitive_files.txt: Discovered sensitive files.
