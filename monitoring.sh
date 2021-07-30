#!/bin/bash


RED="\033[31m"
GREEN="\033[32m"
NC="\033[0m"


Architecture_and_kernel() {
    Architecture=$(uname -a | cut -d " " -f 9)
    Kernel_v=$(uname -v)
    more_info=$(uname -a)
    echo -e "\n    #${GREEN}[Architecture]${NC}: $Architecture" "\n" "    ${GREEN}[kernel version]${NC}: $Kernel_v" "\n     ${GREEN}[more de\
tail]${NC}: $more_info"
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
#top function as well, MiB Mem, and used

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
    nb_partition=$(cat /etc/fstab | grep '^/dev/mapper/' | wc -l)
    echo -e "    #${GREEN}[Last boot]${NC}: $last_reboot"
    if [ ${nb_partition} -gt 0 ]
    then
        echo  -e "    #${GREEN}[LVM use]${NC}: yes"
    else
        echo -e "    #${GREEN}[LVM use]${NC}: no"
    fi
}

nb_active_connection() {
    nb_active_connection=$(ss | grep tcp | wc -l)
    echo -e "    #${GREEN}[Connexions TCP]${NC}: $nb_active_connection ESTABLISHED"
}
# netstat -s -t | sed -e '/Tcp:/!d;:l;n;/^\ /!d;bl'| grep "connections established"
# ss -s | grep estab



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
    nb_sudo=$(grep 'COMMAND='  /var/log/sudo/sudo.log | wc -l)
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




#[PHYSICAL CPU]
#Intel refers to a physical processor as a socket.
#https://www.perfmatrix.com/physical-cpu-and-logical-cpu/
#[VCPU]
#https://webhostinggeeks.com/howto/how-to-display-the-number-of-processors-vcpu-on-linux-vps/
#[CPU load]
#https://support.site24x7.com/portal/en/kb/articles/how-is-cpu-utilization-calculated-for-a-linux-server-monitor
