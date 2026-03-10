# Maher-Framework V7 

Maher-Framework is an automated, smart, and WAF-evasive Bug Bounty Pipeline written in Bash. It is designed to perform deep reconnaissance, smart asset categorization, and targeted vulnerability scanning without triggering Web Application Firewalls. 

**Version 7** introduces advanced methodologies (inspired by top-tier bug hunters), including deep DNS permutations, historical data mining, target-specific wordlist generation, and dynamic custom headers for private Bug Bounty Programs.

##  Key Features

* **Stealth & Deep Reconnaissance:** Combines passive enum (`subfinder`, `cero`) with advanced active permutations (`alterx`) and smart wildcard filtering (`puredns`).
* **Historical & Deep Crawling:** Mines current endpoints using `katana` and uncovers forgotten historical parameters using `gau`.
* **Dynamic WAF Evasion (Custom Headers):** Seamlessly injects your private platform headers (e.g., HackerOne, Bugcrowd) into all underlying tools (`httpx`, `katana`, `nuclei`) to avoid IP bans and rate limits.
* **Smart Asset Categorization:** Automatically groups live targets by technology (WordPress, Nginx, PHP, React, etc.) to save time and RAM.
* **Regex Mining & Target-Specific Wordlists:** Uses a custom Regex Engine to categorize endpoints for targeted attacks (XSS, SQLi, LFI, SSRF, IDOR) and automatically builds a custom fuzzing wordlist from the target's own JavaScript and URL paths.
* **Targeted Attacking (Sniper Mode):** Instead of spraying generic payloads, it matches the right `nuclei` templates with the right targets (e.g., hitting JS files only with token-exposure templates).

##  Prerequisites & Installation

Before running the framework, ensure you have the required Go tools installed and properly added to your `$PATH`.

```bash
# 1. Clone the repository
git clone https://github.com/Mohammed-Maher0/Maher-Framework.git
cd Maher-Framework
chmod +x *.sh

# 2. Install required Go tools (Make sure ~/go/bin is in your PATH)
go install github.com/glebarez/cero@latest
go install github.com/d3mondev/puredns/v2@latest
go install github.com/projectdiscovery/alterx/cmd/alterx@latest
go install github.com/lc/gau/v2/cmd/gau@latest
```

*(Ensure standard tools like `subfinder`, `httpx`, `naabu`, `katana`, and `nuclei` are also installed on your system).*

##  Usage

The framework is controlled by a single master script (`pwn.sh`). It is highly flexible and adapts to your target's requirements.

### Scenario 1: Private Bug Bounty Programs (With Custom Header)
If you are hunting on HackerOne, Bugcrowd, or Intigriti, you usually need to include a custom header to bypass their WAF and identify your traffic. Use the `-H` flag:

```bash
./pwn.sh -d target.com -H "X-Bug-Bounty: HackerOne-your_username"
```
*The framework will automatically export this header and inject it into all requests made by `httpx`, `katana`, and `nuclei`.*

### Scenario 2: Public Targets / VDPs (Without Header)
If you are hunting on a public target or testing your own infrastructure where a custom header is not required, simply run it with the domain flag. The framework will automatically run in standard mode:

```bash
./pwn.sh -d target.com
```

##  Architecture & Pipeline

1. **`recon.sh` (The Eye):** Gathers subdomains, generates permutations, resolves them, scans top ports, extracts technologies, and builds the Tech Database.
2. **`mine.sh` (The Miner):** Fetches historical URLs, crawls live targets, isolates JS files, generates a custom wordlist, and filters parameters using the Maher Regex Engine.
3. **`attack.sh` (The Sniper):** Executes highly targeted `nuclei` scans based on the filtered data (e.g., scanning JS for secrets, attacking specific tech stacks, and probing vulnerable parameters).

## ⚠️ Disclaimer
This tool is for educational purposes and authorized security testing only. Do not use this framework on targets you do not have explicit permission to test. The author is not responsible for any misuse.
