#!/bin/sh
# This script will fetch the Googlevideo ad domains and append them to the Pi-hole block list.
# Run this script daily with a cron job (don't forget to chmod +x)
# 0 * / 4 * * * sudo /home/piscript/ytads.sh> / dev / null

# File to store the YT ad domains
BLACKLIST='/etc/pihole/black.list'
BLACKLISTTXT='/etc/pihole/blacklist.txt'

# Fetch the list of domains, remove the ip's and save them
sudo curl --silent 'https://api.hackertarget.com/hostsearch/?q=googlevideo.com' \
| awk -F, 'NR>1{print $1}' \
| grep -vE "redirector|manifest" > $BLACKLIST

sudo curl --silent 'https://api.hackertarget.com/hostsearch/?q=googlevideo.com' \
| awk -F, 'NR>1{print $1}' \
| grep -vE "redirector|manifest" > $BLACKLISTTXT

wait

# Replace r*.sn*.googlevideo.com URLs to r*---sn-*.googlevideo.com
# and add those to the list too
sudo cat $BLACKLIST | sed -r 's/(^r[[:digit:]]+)(\.)(sn)/\1---\3/' >> $BLACKLIST

sudo cat $BLACKLISTTXT | sed -r 's/(^r[[:digit:]]+)(\.)(sn)/\1---\3/' >> $BLACKLISTTXT

# Scan log file for previously accessed domains
grep '^r([1-9]|1\d|20).*-.*\.googlevideo\.com' /var/log/pihole*.log \
| awk '{print $8}' \
| grep -vE "redirector|manifest" \
| sort | uniq >> $BLACKLIST

grep '^r([1-9]|1\d|20).*-.*\.googlevideo\.com' /var/log/pihole*.log \
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
