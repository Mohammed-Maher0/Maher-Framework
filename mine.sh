#!/bin/bash

WORK_DIR=$1

if [ -z "$WORK_DIR" ]; then
    echo -e "\e[31m[!] Usage: ./mine.sh <work_dir>\e[0m"
    exit 1
fi

# ==========================================
# 0. تجهيز الـ Custom Header (لو المايسترو باعته)
# ==========================================
HEADER_OPTS=()
if [ -n "$CUSTOM_BBP_HEADER" ]; then
    HEADER_OPTS=("-H" "$CUSTOM_BBP_HEADER")
fi

echo "=========================================="
echo " [2] MINING PHASE: GATHERING & FILTERING"
echo "=========================================="

# الدخول لمجلد التارجت وعمل مجلد الـ mining
cd $WORK_DIR
mkdir -p mining

# ==========================================
# Phase 1: تجميع الروابط (من الماضي والحاضر)
# ==========================================
echo "[+] Phase 1: Deep Crawling & Historical Data (GAU + Katana)..."
cat alive.txt | gau --threads 10 > mining/gau_urls.txt
katana -list alive.txt -silent "${HEADER_OPTS[@]}" -depth 3 -jc > mining/katana_urls.txt

# دمج كل اللينكات اللي طلعناها من الأداتين
cat mining/gau_urls.txt mining/katana_urls.txt | sort -u > all_urls.txt
echo "    > Total URLs gathered: $(wc -l < all_urls.txt)"

# ==========================================
# Phase 2: عزل ملفات الـ JS وصناعة القاموس المخصص
# ==========================================
echo "[+] Phase 2: Extracting JS & Building Custom Wordlist..."
# عزل الـ JS
grep -iE "\.js(\?.*)?$" all_urls.txt | sort -u > mining/js_urls.txt
echo "    > JS Files Isolated: $(wc -l < mining/js_urls.txt)"

# صناعة القاموس (تريكة فتحي)
cat all_urls.txt | awk -F/ '{for(i=3;i<=NF;i++) print $i}' | sed 's/?.*//' | tr "[:punct:]" "\n" | sort -u | grep -v "^[0-9]*$" | awk '{ if (length($0) > 3 && length($0) < 20) print $0 }' > mining/custom_wordlist.txt
echo "    > Custom Wordlist built: $(wc -l < mining/custom_wordlist.txt) words"

# ==========================================
# Phase 3: عزل الباراميترز
# ==========================================
echo "[+] Phase 3: Extracting Parameterized URLs..."
grep "=" all_urls.txt | sort -u > all_params.txt
PARAMS_COUNT=$(wc -l < all_params.txt 2>/dev/null || echo "0")
echo "    > Extracted $PARAMS_COUNT URLs with parameters."

# ==========================================
# Phase 4: محرك Maher للفلترة الذكية (Regex Engine)
# ==========================================
echo "[+] Phase 4: Categorizing Parameters for Targeted Attacks..."

grep -iE "[?&](q|s|search|lang|keyword|query|page|view|id|name|callback|jsonp)=" all_params.txt > mining/xss.txt
grep -iE "[?&](id|page|dir|category|sort|user|item|cat|p|article|product)=" all_params.txt > mining/sqli.txt
grep -iE "[?&](file|page|dir|doc|folder|path|include|template|layout)=" all_params.txt > mining/lfi.txt
grep -iE "[?&](url|dest|path|uri|domain|site|out|redirect|next|return|go|target|window)=" all_params.txt > mining/ssrf_redirect.txt
grep -iE "[?&](cmd|exec|ping|run|do|name|q|template|eval|daemon)=" all_params.txt > mining/rce.txt
grep -iE "[?&](id|user_id|account|profile|order|invoice|doc|receipt|bill)=" all_params.txt > mining/idor.txt

echo "    > Categories Created:"
echo "      - XSS:   $(wc -l < mining/xss.txt)"
echo "      - SQLi:  $(wc -l < mining/sqli.txt)"
echo "      - LFI:   $(wc -l < mining/lfi.txt)"
echo "      - SSRF:  $(wc -l < mining/ssrf_redirect.txt)"
echo "      - RCE:   $(wc -l < mining/rce.txt)"
echo "      - IDOR:  $(wc -l < mining/idor.txt)"

echo "[✔] Mining Phase Completed Successfully!"
