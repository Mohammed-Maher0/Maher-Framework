#!/bin/bash
WORK_DIR=$1

echo "=========================================="
echo "💣 [3] ATTACK PHASE: WAF-EVASION MODE"
echo "=========================================="

cd $WORK_DIR
mkdir -p vulns

# 1. صيد أسرار الجافاسكريبت
echo "[+] 1. Hunting for API Keys & Secrets in JS..."
if [ -s mining/js_urls.txt ]; then
    nuclei -l mining/js_urls.txt -tags exposure,token,key -severity info,low,medium,high,critical -rl 50 -c 20 -silent -o vulns/js_secrets.txt
    echo "    > Done. Check vulns/js_secrets.txt"
fi

# 2. الهجوم الموجه على التكنولوجيا (Smart CVE Scanning)
echo "[+] 2. Executing Targeted Tech Attacks..."
for tech in wordpress php nginx apache tomcat nodejs react; do
    if [ -s technologies/${tech}.txt ]; then
        echo "    > Attacking $tech targets..."
        nuclei -l technologies/${tech}.txt -tags ${tech},cve,misconfig -severity info,low,medium,high,critical -rl 50 -c 20 -silent -o vulns/tech_${tech}_vulns.txt
    fi
done

# 3. ضرب الباراميترز (XSS, SQLi, LFI, SSRF, RCE)
echo "[+] 3. Attacking Vulnerable Parameters..."

if [ -s mining/xss.txt ]; then
    echo "    > Testing XSS..."
    nuclei -l mining/xss.txt -tags xss -severity info,low,medium,high,critical -rl 50 -c 20 -silent -o vulns/xss_vulns.txt
fi

if [ -s mining/sqli.txt ]; then
    echo "    > Testing SQLi..."
    nuclei -l mining/sqli.txt -tags sqli -severity info,low,medium,high,critical -rl 50 -c 20 -silent -o vulns/sqli_vulns.txt
fi

if [ -s mining/lfi.txt ]; then
    echo "    > Testing LFI & Path Traversal..."
    nuclei -l mining/lfi.txt -tags lfi -severity info,low,medium,high,critical -rl 50 -c 20 -silent -o vulns/lfi_vulns.txt
fi

if [ -s mining/ssrf_redirect.txt ]; then
    echo "    > Testing SSRF & Open Redirect..."
    nuclei -l mining/ssrf_redirect.txt -tags ssrf,redirect -severity info,low,medium,high,critical -rl 50 -c 20 -silent -o vulns/ssrf_vulns.txt
fi

if [ -s mining/rce.txt ]; then
    echo "    > Testing RCE & Command Injection..."
    nuclei -l mining/rce.txt -tags rce,oast -severity info,low,medium,high,critical -rl 50 -c 20 -silent -o vulns/rce_vulns.txt
fi

# 4. فحص الاستيلاء على الدومينات (Subdomain Takeover)
echo "[+] 4. Checking Subdomain Takeovers..."
if [ -s all_subs.txt ]; then
    nuclei -l all_subs.txt -tags takeover -severity info,low,medium,high,critical -rl 50 -c 20 -silent -o vulns/takeovers.txt
fi

echo "[✔] Attack Phase Completed!"
