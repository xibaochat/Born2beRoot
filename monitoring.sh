#!/bin/bash

RED="\033[31m"
GREEN="\033[32m"
NC="\033[0m"


### broadcast() {
### 	NOW=$(date +%c)
### 	echo -n -e "Broadcast message from ${GREEN}$USER${NC}"
### 	echo " ($NOW)"| tr [:lower:] [:upper:]
### }

Architecture_and_kernel() {
	Architecture=$(uname -i)
	Kernel_v=$(uname -v)
	more_info=$(uname -a)
	echo -e "\n    #${GREEN}[Architecture]${NC}: $Architecture" "\n" "    ${GREEN}[kernel version]${NC}: $Kernel_v" "\n     ${GREEN}[more detail]${NC}: $more_info"
}

cpu_physcial() {
	physical_core=$(lscpu | egrep 'Socket' | tr -d " " | cut -d ":" -f 2)
	echo -e "    #${GREEN}[CPU physical]${NC}: $physical_core"
}

vcpu() {
	echo -e -n "    #${GREEN}[vCPU]${NC}: "
	cat /proc/cpuinfo | grep processor | wc -l
}

Memory_usage() {
	total_m=$(free -m | grep Mem: | grep -o -E '[0-9]+' | head -n 1)
	used_m=$(free -m | grep Mem: | grep -o -E '[0-9]+' | sed -n -e '2{p;q}' )
	echo -e  "    #${GREEN}[Memory Usage]${NC}: $used_m/${total_m}MB" "($(( 100*$used_m/$total_m ))%)"
}

disk_usage() {
	total_disk=$(df | grep '^/dev/' | awk '{s+=$2} END {print s/1048576}')
	used=$(df | grep '^/dev/' | awk '{s+=$3} END {print s/1048576}')
	used_int=$(df | grep '^/dev/' | awk '{s+=$3} END {print s}')
	total_m_int=$(df | grep '^/dev/' | awk '{s+=$2} END {print s}')
	echo -e "    #${GREEN}[Disk Usage]${NC}: ${used}/${total_disk}Gb" "($(( 100*${used_int}/$total_m_int ))%)"
}

cpu_load() {
	c_load=$(top -bn 1 |grep "Cpu(s)" | awk '{print 100-$8}')
	echo -e "    #${GREEN}[CPU load]${NC}: $c_load%"
}

last_reboot() {
	last_reboot=$(who -b | awk '{print $3 " " $4}')
# 	last_reboot=$(uptime | perl -ne '/.*up +(?:(\d+) days?,? +)?(\d+):(\d+),.*/; $total=((($1*24+$2)*60+$3)*60);
# $now=time(); $now-=		 $total; $now=localtime($now); print $now,"\n";')

	# 	echo -e "    #${GREEN}[Last boot]${NC}: $last_reboot"
	echo -e "    #${GREEN}[Last boot]${NC}: $last_reboot"

	echo -e "    #${GREEN}[LVM use]${NC}: DID NOT KNOW YET"
}

nb_active_connection() {
	nb_active_connection=$(ss | grep tcp | wc -l)
	echo -e "    #${GREEN}[Connexions TCP]${NC}: $nb_active_connection ESTABLISHED"
}

user_log() {
	nb_user=$(who | wc -l)
	name=$(who | awk -F" " '{print $1}')
	echo -e "    #${GREEN}[User log]${NC}: $nb_user $name"
}

network(){
	net_int=$(ip -4 -o a | grep -v '1: lo' | head -n 1 | awk '{print $2}')
	ipv4=$(ip -f inet addr show ${net_int} | grep inet | awk '{print $2}' | cut -d '/' -f 1)
	mac_add=$(ip -f link addr show ${net_int} | tail -n 1 | awk '{print $2}')
	echo -e "    #${GREEN}[Network] IP${NC}: $ipv4 ($mac_add)"
}

nb_sudo() {
	nb_sudo=$(grep 'sudo:' /var/log/auth.log | grep 'COMMAND=' | wc -l)
	echo -e "    #${GREEN}[Sudo]${NC}: ${nb_sudo} cmd"
}


Architecture_and_kernel
cpu_physcial
vcpu
Memory_usage
disk_usage
cpu_load
last_reboot
nb_active_connection
user_log
network
nb_sudo
