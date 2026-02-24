#!/bin/bash

TARGET=$1

if [ -z "$TARGET" ]; then
    echo -e "\e[31m[!] Usage: ./pwn.sh <domain.com>\e[0m"
    exit 1
fi

TIMESTAMP=$(date +%F_%H-%M)
WORK_DIR="targets/${TARGET}_hunt_${TIMESTAMP}"

echo -e "\e[32m"
echo "================================================="
echo "   🐉 MAHER FRAMEWORK V6 - DRAGON EDITION 🐉   "
echo "================================================="
echo "🎯 TARGET:  $TARGET"
echo "📁 FOLDER:  $WORK_DIR"
echo "🕒 TIME:    $TIMESTAMP"
echo "================================================="
echo -e "\e[0m"

# التعديل هنا: المايسترو هيسأل الـ Recon، لو فشل هيوقف السيستم كله
if ! ./recon.sh $TARGET $WORK_DIR; then
    echo -e "\e[31m[!] Mission Aborted: No targets found or Recon failed.\e[0m"
    exit 1
fi

./mine.sh $WORK_DIR
./attack.sh $WORK_DIR

echo -e "\e[32m"
echo "================================================="
echo "✅ MISSION COMPLETE!"
echo "📄 Check your results in: $WORK_DIR"
echo "================================================="
echo -e "\e[0m"
