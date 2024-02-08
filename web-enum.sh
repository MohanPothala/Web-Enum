#!/bin/bash

url=$1

if [ ! -d "$url" ];then
    mkdir $url
fi

if [ ! -d "$url/recon" ];then
    mkdir $url/recon
fi

if [ ! -d "$url/recon/httprobe" ];then
    mkdir $url/recon/httprobe
fi

if [ ! -d "$url/recon/gowitness" ];then
    mkdir $url/recon/gowitness
fi

if [ ! -f "$url/recon/httprobe/alive.txt" ];then
    touch $url/recon/httprobe/alive.txt
fi

if [ ! -f "$url/recon/final.txt" ];then
    touch $url/recon/final.txt
fi

echo "[+] Harvesting subdomains with assetfinder..."
assetfinder $url >> $url/recon/assets.txt
cat $url/recon/assets.txt | grep $1 >> $url/recon/final.txt
rm $url/recon/assets.txt

echo "[+] Double checking for subdomains with amass..."
amass enum -d $url >> $url/recon/f.txt
sort -u $url/recon/f.txt >> $url/recon/final.txt
rm $url/recon/f.txt

echo "[+] Probing for alive domains..."
cat $url/recon/final.txt | sort -u | httprobe -s -p https:443 | sed 's/https\?:\/\///' | tr -d ':443' >> $url/recon/httprobe/a.txt
sort -u $url/recon/httprobe/a.txt > $url/recon/httprobe/alive.txt
rm $url/recon/httprobe/a.txt

echo "[+] Running GoWitness..."
gowitness file -f $url/recon/httprobe/alive.txt -P $url/recon/gowitness

echo "Reconnaissance completed."
