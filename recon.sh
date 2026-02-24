#!/bin/bash
TARGET=$1
WORK_DIR=$2

echo "=========================================="
echo "🔍 [1] RECON Phase: LIGHTWEIGHT & FAST"
echo "=========================================="

mkdir -p $WORK_DIR
cd $WORK_DIR

echo "[+] 1. Finding Subdomains (subfinder)..."
echo $TARGET > subs_raw.txt 
subfinder -d $TARGET -silent >> subs_raw.txt
cat subs_raw.txt | sort -u > all_subs.txt
echo "    > Subdomains Found: $(wc -l < all_subs.txt)"

echo "[+] 2. Checking Live Hosts (Fast Pulse)..."
httpx -l all_subs.txt -silent -t 50 -o live_pulse.txt
echo "    > Live Hosts: $(wc -l < live_pulse.txt)"

if [ ! -s live_pulse.txt ]; then
    echo -e "\e[31m[!] No live hosts found. Exiting recon.\e[0m"
    exit 1
fi

sed -E 's/https?:\/\///' live_pulse.txt | sed 's/:.*//' > clean_hosts.txt

echo "[+] 3. Port Scanning Top 100 (naabu)..."
# حماية هندسية: بنعمل الملف فاضي الأول عشان لو نابو ضربت، السكريبت ميكراشش
touch active_ports.txt 
naabu -l clean_hosts.txt -top-ports 100 -rate 100 -c 20 -silent -o active_ports.txt || true
echo "    > Extra Ports Found: $(wc -l < active_ports.txt 2>/dev/null || echo "0")"

echo "[+] 4. Deep Tech Extraction (RAM Saver Mode)..."
cat live_pulse.txt active_ports.txt 2>/dev/null | sort -u > final_targets.txt
# شيلنا السكرين شوت والكروم عشان نحافظ على رامات الجهاز والسكريبت ميموتش
httpx -l final_targets.txt -silent -sc -title -td -rl 50 -t 20 -o live_tech.txt

awk '{print $1}' live_tech.txt > live.txt

echo "[+] 5. Building Tech Database (Asset Management)..."
mkdir -p technologies
grep -i "wordpress" live_tech.txt | awk '{print $1}' > technologies/wordpress.txt
grep -i "php" live_tech.txt | awk '{print $1}' > technologies/php.txt
grep -i "react" live_tech.txt | awk '{print $1}' > technologies/react.txt
grep -i "nginx" live_tech.txt | awk '{print $1}' > technologies/nginx.txt
grep -i "apache" live_tech.txt | awk '{print $1}' > technologies/apache.txt
grep -i "tomcat" live_tech.txt | awk '{print $1}' > technologies/tomcat.txt
grep -i "node.js" live_tech.txt | awk '{print $1}' > technologies/nodejs.txt
echo "    > Tech DB created successfully."

echo "[+] 6. Stealth Crawling (katana)..."
katana -list live.txt -jc -d 3 -rl 50 -c 10 -silent > endpoints.txt
echo "    > Endpoints Extracted: $(wc -l < endpoints.txt)"

echo "[✔] Recon Phase Completed!"
exit 0
