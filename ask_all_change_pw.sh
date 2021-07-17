echo "script to ask user to change password\n"

USERNAMES=($(getent passwd | grep /bin/bash | cut -d ':' -f 1))
MYSELF=($whoami)

for user in ${USERNAMES[*]}
do
    if [[ $user != $MYSELF ]]
    then
        echo $user
        sudo chage -d 0 $user
        chage -l $user
    fi
done
