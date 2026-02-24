#  Maher-Framework V6 



Maher-Framework is an automated, smart, and WAF-evasive Bug Bounty Pipeline written in Bash. It is designed to perform deep reconnaissance, smart asset categorization, and targeted vulnerability scanning without triggering Web Application Firewalls.



##  Features

- **Stealth Reconnaissance:** Uses `subfinder`, `httpx`, and `naabu` with optimized rate limits.

- **Smart Asset Categorization:** Automatically groups live targets by technology (WordPress, Nginx, PHP, React, etc.).

- **Deep Crawling & Regex Mining:** Uses `katana` to extract endpoints, then a custom Regex Engine filters them for targeted attacks (XSS, SQLi, LFI, SSRF, RCE, IDOR, API Keys).

- **Targeted Attacking (Sniper Mode):** Instead of spraying payloads, it matches the right `nuclei` templates with the right targets (e.g., hitting JS files only with token-exposure templates).

- **WAF Evasion:** Built-in concurrency controls (`-rl 50 -c 20`) to stay under the radar.



##  Installation
```bash
git clone https://github.com/Mohammed-Maher0/Maher-Framework.git
cd Maher-Framework
chmod +x *.sh
