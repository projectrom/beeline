#!/bin/bash

#Let's install or renew packages
apt install -y sshpass 1>/dev/null 2>/dev/null
yum install -y sshpass 1>/dev/null 2>/dev/null

DATE=$(date +"%Y_%m_%d-%H_%M_%S")
FILE="./list.txt" #Our file with credentials
LOG="./log_"$DATE".txt" #Our log file
COMMAND="hostname"

#Function executes command on remote host
CMD() {
/usr/bin/sshpass -p "$1" /usr/bin/ssh -o StrictHostKeyChecking=no -n "$2"@"$3" "$COMMAND" 2>/dev/null
}

tail -n +2 $FILE | while read LINE
do

    USER=$(echo $LINE | awk '{print $1}')
    PW=$(echo $LINE | awk '{print $2}')
    HOST=$(echo $LINE | awk '{print $3}')
    echo -ne "$HOST\t\t" >> $LOG
    CMD $PW $USER $HOST 1>> $LOG; RC=$?

    if [ $RC = 255 ]; then
        echo "SSH connection is unavailable" >> $LOG
    elif [ $RC = 5 ]; then
        echo "Seems user or password is not correct" >> $LOG
    elif [  $RC != 0 ] && [ $RC != 5 ] && [ $RC != 255 ]; then
       echo "Something went wrong. Cannot connect to host" >> $LOG
    fi

done


