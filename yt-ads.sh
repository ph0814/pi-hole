#!/bin/sh
# This script will fetch the Googlevideo ad domains and append them to the Pi-hole block list.
# Run this script daily with a cron job (don't forget to chmod +x)
# 0 * / 4 * * * sudo /home/piscript/yt-ads.sh> / dev / null

# File to store the YT ad domains
APP_ID='YOUR-APP-ID'
BLACKLIST='/etc/pihole/black.list'
BLACKLISTTXT='/etc/pihole/blacklist.txt'

# Fetch the list of domains, remove the ip's and save them
sudo curl --silent 'https://api.hackertarget.com/hostsearch/?q=googlevideo.com' \
| awk -F, 'NR>1{print $1}' \
| grep -vE 'redirector|manifest' > $BLACKLIST

sudo curl --silent 'https://api.hackertarget.com/hostsearch/?q=googlevideo.com' \
| awk -F, 'NR>1{print $1}' \
| grep -vE 'redirector|manifest' > $BLACKLISTTXT

wait

# Replace r*.sn*.googlevideo.com URLs to r*---sn-*.googlevideo.com
# and add those to the list too
sudo cat $BLACKLIST | sed -r 's/(^r[[:digit:]]+)(\.)(sn)/\1---\3/' >> $BLACKLIST

sudo cat $BLACKLISTTXT | sed -r 's/(^r[[:digit:]]+)(\.)(sn)/\1---\3/' >> $BLACKLISTTXT

sudo curl --silent 'http://api.wolframalpha.com/v2/query?input=googlevideo.com&appid=APP_ID&format=plaintext&podstate=WebSiteStatisticsPod:InternetData__Subdomains&podstate=WebSiteStatisticsPod:InternetData__Subdomains_More' \
| awk -F, 'NR>1{print $1}' \
| grep -Po '^r([1-9]|1\d|25).*(sn\-).*\.googlevideo\.com' \
| sort | uniq >> $BLACKLIST

sudo curl --silent 'http://api.wolframalpha.com/v2/query?input=googlevideo.com&appid=APP_ID&format=plaintext&podstate=WebSiteStatisticsPod:InternetData__Subdomains&podstate=WebSiteStatisticsPod:InternetData__Subdomains_More' \
| awk -F, 'NR>1{print $1}' \
| grep -Po '^r([1-9]|1\d|25).*(sn\-).*\.googlevideo\.com' \
| sort | uniq >> $BLACKLISTTXT

sudo curl --silent 'https://raw.githubusercontent.com/HenningVanRaumle/pihole-ytadblock/master/googlevideo.com%20domains/adverisment.txt' \
| awk -F, 'NR>1{print $1}' \
| grep -Po '^r([1-9]|1\d|25).*(sn\-).*\.googlevideo\.com' \
| sort | uniq >> $BLACKLIST

sudo curl --silent 'https://raw.githubusercontent.com/HenningVanRaumle/pihole-ytadblock/master/googlevideo.com%20domains/adverisment.txt' \
| awk -F, 'NR>1{print $1}' \
| grep -Po '^r([1-9]|1\d|25).*(sn\-).*\.googlevideo\.com' \
| sort | uniq >> $BLACKLISTTXT

sudo curl --silent 'https://raw.githubusercontent.com/HenningVanRaumle/pihole-ytadblock/master/googlevideo.com%20domains/normal%20videos.txt' \
| awk -F, 'NR>1{print $1}' \
| grep -Po '^r([1-9]|1\d|25).*(sn\-).*\.googlevideo\.com' \
| sort | uniq >> $BLACKLIST

sudo curl --silent 'https://raw.githubusercontent.com/HenningVanRaumle/pihole-ytadblock/master/googlevideo.com%20domains/normal%20videos.txt' \
| awk -F, 'NR>1{print $1}' \
| grep -Po '^r([1-9]|1\d|25).*(sn\-).*\.googlevideo\.com' \
| sort | uniq >> $BLACKLISTTXT

sudo curl --silent 'https://raw.githubusercontent.com/HenningVanRaumle/pihole-ytadblock/master/ytadblock.txt' \
| awk -F, 'NR>1{print $1}' \
| grep -Po '^r([1-9]|1\d|25).*(sn\-).*\.googlevideo\.com' \
| sort | uniq >> $BLACKLIST

sudo curl --silent 'https://raw.githubusercontent.com/HenningVanRaumle/pihole-ytadblock/master/ytadblock.txt' \
| awk -F, 'NR>1{print $1}' \
| grep -Po '^r([1-9]|1\d|25).*(sn\-).*\.googlevideo\.com' \
| sort | uniq >> $BLACKLISTTXT

sudo curl --silent 'https://adblock.amroemischengutshof.de/youtube-ads-list.txt' \
| awk -F, 'NR>1{print $1}' \
| grep -Po '^r([1-9]|1\d|25).*(sn\-).*\.googlevideo\.com' \
| sort | uniq >> $BLACKLIST

sudo curl --silent 'https://adblock.amroemischengutshof.de/youtube-ads-list.txt' \
| awk -F, 'NR>1{print $1}' \
| grep -Po '^r([1-9]|1\d|25).*(sn\-).*\.googlevideo\.com' \
| sort | uniq >> $BLACKLISTTXT

# Scan log file for previously accessed domains
grep '^r([1-9]|1\d|25).*(sn\-).*\.googlevideo\.com' /var/log/pihole*.log \
| awk '{print $8}' \
| grep -vE "redirector|manifest" \
| sort | uniq >> $BLACKLIST

grep '^r([1-9]|1\d|25).*(sn\-).*\.googlevideo\.com' /var/log/pihole*.log \
| awk '{print $8}' \
| grep -vE "redirector|manifest" \
| sort | uniq >> $BLACKLISTTXT

#wait

# check to see if gawk is installed. if not it will install it
#dpkg -l | grep -qw gawk || sudo apt-get install gawk

wait

# remove the duplicate records in place
gawk -i inplace '!a[$0]++' $BLACKLIST

gawk -i inplace '!a[$0]++' $BLACKLISTTXT
