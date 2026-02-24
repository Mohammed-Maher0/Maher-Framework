#!/bin/bash
WORK_DIR=$1

echo "=========================================="
echo " [2] MINING PHASE: DATA FILTERING"
echo "=========================================="

cd $WORK_DIR
mkdir -p mining

# 1. عزل الروابط اللي فيها باراميترز بس (علامة =)
grep "=" endpoints.txt | sort -u > all_params.txt
PARAMS_COUNT=$(wc -l < all_params.txt 2>/dev/null || echo "0")
echo "[+] Extracted $PARAMS_COUNT URLs with parameters."

# 2. عزل ملفات الجافاسكريبت (لصيد الأسرار)
grep -iE "\.js(\?.*)?$" endpoints.txt | sort -u > mining/js_urls.txt
echo "    > JS Files Isolated: $(wc -l < mining/js_urls.txt)"

# 3. محرك Maher للفلترة الذكية (Regex Engine)
echo "[+] Categorizing Parameters for Targeted Attacks..."

# فلترة XSS
grep -iE "[?&](q|s|search|lang|keyword|query|page|view|id|name|callback|jsonp)=" all_params.txt > mining/xss.txt
# فلترة SQLi
grep -iE "[?&](id|page|dir|category|sort|user|item|cat|p|article|product)=" all_params.txt > mining/sqli.txt
# فلترة LFI & Path Traversal
grep -iE "[?&](file|page|dir|doc|folder|path|include|template|layout)=" all_params.txt > mining/lfi.txt
# فلترة SSRF & Open Redirect
grep -iE "[?&](url|dest|path|uri|domain|site|out|redirect|next|return|go|target|window)=" all_params.txt > mining/ssrf_redirect.txt
# فلترة RCE & Command Injection
grep -iE "[?&](cmd|exec|ping|run|do|name|q|template|eval|daemon)=" all_params.txt > mining/rce.txt
# فلترة IDOR (للثغرات المنطقية)
grep -iE "[?&](id|user_id|account|profile|order|invoice|doc|receipt|bill)=" all_params.txt > mining/idor.txt

echo "    > Categories Created:"
echo "      - XSS:   $(wc -l < mining/xss.txt)"
echo "      - SQLi:  $(wc -l < mining/sqli.txt)"
echo "      - LFI:   $(wc -l < mining/lfi.txt)"
echo "      - SSRF:  $(wc -l < mining/ssrf_redirect.txt)"
echo "      - RCE:   $(wc -l < mining/rce.txt)"
echo "      - IDOR:  $(wc -l < mining/idor.txt)"

echo "[✔] Mining Phase Completed!"
