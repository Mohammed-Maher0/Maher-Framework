#!/bin/bash

# 1. تعريف مصفوفة (Array) فاضية للهيدر
HEADER_OPTS=()
domain=""

# 2. تظبيط الـ getopts عشان يقبل حرف الـ H
while getopts "d:H:" opt; do
  case $opt in
    d) domain=$OPTARG ;;
    H) HEADER_OPTS=("-H" "$OPTARG") ;; # هنا لو ضاف الهيدر، هيتخزن صح بالمسافات
    \?) echo "Usage: $0 -d <domain> [-H <Custom-Header>]"; exit 1 ;;
  esac
done

echo "🎯 Target: $domain"
if [ ${#HEADER_OPTS[@]} -ne 0 ]; then
    echo "🛡️ Injecting Custom Header: ${HEADER_OPTS[1]}"
fi

# ==========================================
# 3. إزاي تحطها جنب الأدوات تحت في الكود؟
# ==========================================

# كل اللي هتعمله إنك هتحط "${HEADER_OPTS[@]}" جنب httpx و nuclei و katana بالشكل ده:

echo "🚀 Running HTTPX..."
cat domains.txt | httpx "${HEADER_OPTS[@]}" -sc -title -o alive.txt

echo "☢️ Running Nuclei..."
nuclei -l alive.txt "${HEADER_OPTS[@]}" -t cves/ -o nuclei_output.txt

echo "🕷️ Running Katana..."
katana -u alive.txt "${HEADER_OPTS[@]}" -o endpoints.txt
