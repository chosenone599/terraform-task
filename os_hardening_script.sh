#!/bin/bash
#
# Title: os_hardening_script.sh
# Auth: JW
# Required: post-install hardening of Linux server 
#

LOG=/tmp/os_hardening.log.$$
echo "Removing unecessary services.." >> $LOG
sudo yum -y remove sendmail telnet-server rsh-server telnet
echo "services removed" >> $LOG

# Secure Cron
echo "Locking down Cron..." >> $LOG
sudo touch /etc/cron.allow
sudo chmod 600 /etc/cron.allow
sudo awk -F: '{print $1}' /etc/passwd | grep -v root > /etc/cron.deny
echo "Cron secured..." >> $LOG
