#!/bin/bash

TARGET=""
CUSTOM_HEADER=""

# 1. استقبال المدخلات (الدومين بـ -d والهيدر بـ -H)
while getopts "d:H:" opt; do
  case $opt in
    d) TARGET="$OPTARG" ;;
    H) CUSTOM_HEADER="$OPTARG" ;;
    \?) echo -e "\e[31m[!] Usage: $0 -d <domain.com> [-H \"Header: Value\"]\e[0m"; exit 1 ;;
  esac
done

# 2. التأكد من إدخال الدومين (حماية عشان السكريبت ميكراشش)
if [ -z "$TARGET" ]; then
    echo -e "\e[31m[!] Error: Target domain is required!\e[0m"
    echo -e "\e[33m[?] Usage: ./pwn.sh -d <domain.com> [-H \"X-Bug-Bounty: HackerOne...\"]\e[0m"
    exit 1
fi

# 3. السحر هنا: تصدير الهيدر للبيئة (Export) 
# السطر ده هو اللي بيخلي recon.sh و mine.sh و attack.sh يشوفوا الهيدر من غير ما نبعتهولهم في الأمر
if [ -n "$CUSTOM_HEADER" ]; then
    export CUSTOM_BBP_HEADER="$CUSTOM_HEADER"
fi

TIMESTAMP=$(date +%F_%H-%M)
WORK_DIR="targets/${TARGET}_hunt_${TIMESTAMP}"
mkdir -p $WORK_DIR

echo -e "\e[32m"
echo "================================================="
echo "    MAHER FRAMEWORK V7 (The Mastermind)          "
echo "================================================="
echo "🎯 TARGET:  $TARGET"
echo "📁 FOLDER:  $WORK_DIR"
echo "🕒 TIME:    $TIMESTAMP"
if [ -n "$CUSTOM_HEADER" ]; then
    echo "🛡️ HEADER:  $CUSTOM_HEADER"
fi
echo "================================================="
echo -e "\e[0m"

# ==========================================
# 4. تشغيل مراحل الفريم ورك بالترتيب
# ==========================================

echo -e "\e[34m[>] Launching Phase 1: RECON...\e[0m"
if ! ./recon.sh $TARGET $WORK_DIR; then
    echo -e "\e[31m[!] Mission Aborted: Recon failed.\e[0m"
    exit 1
fi

echo -e "\e[34m[>] Launching Phase 2: MINING...\e[0m"
./mine.sh $WORK_DIR

echo -e "\e[34m[>] Launching Phase 3: ATTACK...\e[0m"
./attack.sh $WORK_DIR

echo -e "\e[32m"
echo "================================================="
echo "✅ MISSION COMPLETE!"
echo "📄 Check your results in: $WORK_DIR"
echo "================================================="
echo -e "\e[0m"
