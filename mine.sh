#!/bin/bash

TARGET=$1
WORK_DIR=$2

if [ -z "$TARGET" ] || [ -z "$WORK_DIR" ]; then
    echo -e "\e[31m[!] Usage: ./recon.sh <domain.com> <work_dir>\e[0m"
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
echo "🔍 [1] RECON Phase: DEEP & CATEGORIZED (V7)"
echo "=========================================="

mkdir -p $WORK_DIR
cd $WORK_DIR

# ==========================================
# Phase 1: Passive Recon (Fast & Wide)
# ==========================================
echo "[+] 1. Passive Enumeration (subfinder + cero)..."
echo $TARGET > subs_raw.txt 
subfinder -d $TARGET -all -silent >> subs_raw.txt
cero $TARGET 2>/dev/null | sed 's/^\*\.//' | grep "\.$TARGET$" >> subs_raw.txt 
cat subs_raw.txt | sort -u > passive_subs.txt
echo "    > Subdomains Found Passively: $(wc -l < passive_subs.txt)"

# ==========================================
# Phase 2: Resolving & Filtering Wildcards
# ==========================================
echo "[+] 2. Downloading Fresh Resolvers & Resolving..."
wget -q https://raw.githubusercontent.com/trickest/resolvers/main/resolvers-trusted.txt -O resolvers.txt
puredns resolve passive_subs.txt -r resolvers.txt --write resolved_subs.txt -q
echo "    > Valid Subs: $(wc -l < resolved_subs.txt)"

# ==========================================
# Phase 3: Permutations (The Sec Fathy Trick)
# ==========================================
echo "[+] 3. Generating & Resolving Permutations (alterx)..."
cat resolved_subs.txt | alterx -silent > alterx_subs.txt
puredns resolve alterx_subs.txt -r resolvers.txt --write resolved_alterx.txt -q
cat resolved_subs.txt resolved_alterx.txt | sort -u > all_valid_subs.txt
echo "    > Total Valid Subdomains (Including Permutations): $(wc -l < all_valid_subs.txt)"

# ==========================================
# Phase 4: Port Scanning (Naabu) - من كودك القديم
# ==========================================
echo "[+] 4. Port Scanning Top 100 (naabu)..."
touch active_ports.txt 
# بنعمل سكان على الدومينات الصالحة بس عشان نوفر وقت
naabu -l all_valid_subs.txt -top-ports 100 -rate 1000 -c 50 -silent -o active_ports.txt || true
echo "    > Extra Ports Found: $(wc -l < active_ports.txt 2>/dev/null || echo "0")"

# دمج الدومينات الأساسية مع البورتات المفتوحة
cat all_valid_subs.txt active_ports.txt 2>/dev/null | sort -u > final_targets.txt

# ==========================================
# Phase 5: Deep Tech Extraction (httpx)
# ==========================================
echo "[+] 5. Deep Tech Extraction (RAM Saver Mode)..."
# httpx هيشوف مين عايش من البورتات دي، ويجيب التكنولوجيا
httpx -l final_targets.txt "${HEADER_OPTS[@]}" -silent -sc -title -td -rl 50 -t 20 -o live_tech.txt

if [ ! -s live_tech.txt ]; then
    echo -e "\e[31m[!] No live hosts found. Exiting recon.\e[0m"
    exit 1
fi

awk '{print $1}' live_tech.txt > alive.txt
echo "    > Live Hosts & Ports: $(wc -l < alive.txt)"

# ==========================================
# Phase 6: Building Tech Database - من كودك القديم
# ==========================================
echo "[+] 6. Building Tech Database (Asset Management)..."
mkdir -p technologies
grep -i "wordpress" live_tech.txt | awk '{print $1}' > technologies/wordpress.txt
grep -i "php" live_tech.txt | awk '{print $1}' > technologies/php.txt
grep -i "react" live_tech.txt | awk '{print $1}' > technologies/react.txt
grep -i "nginx" live_tech.txt | awk '{print $1}' > technologies/nginx.txt
grep -i "apache" live_tech.txt | awk '{print $1}' > technologies/apache.txt
grep -i "tomcat" live_tech.txt | awk '{print $1}' > technologies/tomcat.txt
grep -i "node.js" live_tech.txt | awk '{print $1}' > technologies/nodejs.txt
echo "    > Tech DB created successfully in 'technologies/'."

echo "[✔] Recon Phase Completed Perfectly!"
