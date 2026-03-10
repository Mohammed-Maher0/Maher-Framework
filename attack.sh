#!/bin/bash

WORK_DIR=$1

if [ -z "$WORK_DIR" ]; then
    echo -e "\e[31m[!] Usage: ./attack.sh <work_dir>\e[0m"
    exit 1
fi

echo -e "\e[31m==========================================\e[0m"
echo -e "\e[31m ☢️ [3] ATTACK PHASE: WAF-EVASION & TARGETED\e[0m"
echo -e "\e[31m==========================================\e[0m"

# ==========================================
# 0. تجهيز الـ Custom Header (الدرع بتاعنا ضد الـ WAF)
# ==========================================
HEADER_OPTS=()
if [ -n "$CUSTOM_BBP_HEADER" ]; then
    HEADER_OPTS=("-H" "$CUSTOM_BBP_HEADER")
    echo -e "\e[33m[🛡️] Shield ON: Injecting BBP Header in all Nuclei requests.\e[0m"
fi

cd $WORK_DIR
mkdir -p vulns

# ==========================================
# 1. صيد أسرار الجافاسكريبت (JS Secrets - Sec Fathy Tip)
# ==========================================
echo "[+] 1. Hunting for API Keys & Secrets in JS..."
if [ -s mining/js_urls.txt ]; then
    nuclei -l mining/js_urls.txt "${HEADER_OPTS[@]}" -tags exposure,token,key -severity info,low,medium,high,critical -rl 50 -c 20 -silent -o vulns/js_secrets.txt
    echo "    > Done. Check vulns/js_secrets.txt"
fi

# ==========================================
# 2. الهجوم الموجه على التكنولوجيا (Smart Tech Exploitation)
# ==========================================
echo "[+] 2. Executing Targeted Tech Attacks (Saving Time & RAM)..."
for tech in wordpress php nginx apache tomcat nodejs react; do
    if [ -s technologies/${tech}.txt ]; then
        echo "    > 🎯 Attacking $tech targets..."
        nuclei -l technologies/${tech}.txt "${HEADER_OPTS[@]}" -tags ${tech},cve,misconfig -severity info,low,medium,high,critical -rl 50 -c 20 -silent -o vulns/tech_${tech}_vulns.txt
    fi
done

# ==========================================
# 3. ضرب الباراميترز (Targeted Injection)
# ==========================================
echo "[+] 3. Attacking Vulnerable Parameters (DAST & CVEs)..."

if [ -s mining/xss.txt ]; then
    echo "    > 🕷️ Testing XSS..."
    nuclei -l mining/xss.txt "${HEADER_OPTS[@]}" -tags xss,dast -severity info,low,medium,high,critical -rl 50 -c 20 -silent -o vulns/xss_vulns.txt
fi

if [ -s mining/sqli.txt ]; then
    echo "    > 💉 Testing SQLi..."
    nuclei -l mining/sqli.txt "${HEADER_OPTS[@]}" -tags sqli,dast -severity info,low,medium,high,critical -rl 50 -c 20 -silent -o vulns/sqli_vulns.txt
fi

if [ -s mining/lfi.txt ]; then
    echo "    > 📂 Testing LFI & Path Traversal..."
    nuclei -l mining/lfi.txt "${HEADER_OPTS[@]}" -tags lfi,dast -severity info,low,medium,high,critical -rl 50 -c 20 -silent -o vulns/lfi_vulns.txt
fi

if [ -s mining/ssrf_redirect.txt ]; then
    echo "    > 🔄 Testing SSRF & Open Redirect..."
    nuclei -l mining/ssrf_redirect.txt "${HEADER_OPTS[@]}" -tags ssrf,redirect,oast -severity info,low,medium,high,critical -rl 50 -c 20 -silent -o vulns/ssrf_vulns.txt
fi

if [ -s mining/rce.txt ]; then
    echo "    > 💻 Testing RCE & Command Injection..."
    nuclei -l mining/rce.txt "${HEADER_OPTS[@]}" -tags rce,oast -severity info,low,medium,high,critical -rl 50 -c 20 -silent -o vulns/rce_vulns.txt
fi

# تنبيه للاختبار اليدوي للـ IDOR (لأن الأدوات غبية فيها)
if [ -s mining/idor.txt ]; then
    echo -e "\e[33m    > ⚠️ Note: IDOR endpoints saved in mining/idor.txt. (Manual testing highly recommended!)\e[0m"
fi

# ==========================================
# 4. فحص الاستيلاء على الدومينات (Subdomain Takeover)
# ==========================================
echo "[+] 4. Checking Subdomain Takeovers (Including Permutations)..."
# بنستخدم all_valid_subs.txt لأن جواه الدومينات الأساسية ودومينات الـ alterx كمان
if [ -s all_valid_subs.txt ]; then
    nuclei -l all_valid_subs.txt "${HEADER_OPTS[@]}" -tags takeover -severity info,low,medium,high,critical -rl 50 -c 20 -silent -o vulns/takeovers.txt
fi

# ==========================================
# 5. تذكير بالقاموس المخصص (Custom Wordlist)
# ==========================================
if [ -s mining/custom_wordlist.txt ]; then
    echo -e "\e[34m[💡] Pro Tip: Don't forget to use your Custom Wordlist for manual FFUF hunting:\e[0m"
    echo "      ffuf -w mining/custom_wordlist.txt -u https://TARGET/FUZZ"
fi

echo -e "\e[32m[✔] Attack Phase Completed! Check the 'vulns' folder for bounties 💰\e[0m"
