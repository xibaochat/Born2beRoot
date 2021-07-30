#!/bin/bash


RED="\033[31m"
GREEN="\033[32m"
NC="\033[0m"

echo "script to ask user to change password"

USERNAMES=($(getent passwd | grep /bin/bash | cut -d ':' -f 1))
MYSELF=$(whoami)
echo $MYSELF
for user in ${USERNAMES[*]}
do
   sudo chage -m 2 -M 30 -W 7 $user
   if [[ $user != $MYSELF ]]
   then
        echo $user
        sudo chage -m 2 -M 30 -W 7 $user
        sudo chage -d 0 $user
        sleep 1
        sudo chage -l $user
   fi
done

echo  $MYSELF " change password"
sleep 1
sudo chage -d 0 $MYSELF
sleep 1
sudo chage -l $MYSELF
