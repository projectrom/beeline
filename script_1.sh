#!/bin/bash

DATE=$(date +"%Y_%m_%d-%H_%M_%S")
FILE="./list.txt" #Our file with credentials
LOG="./log_"$DATE".txt" #Our log file
COMMAND="hostname"

#Function executes command on remote host
CMD() {
expect -c "
   set timeout 1
   spawn ssh "$2"@"$3" "$COMMAND"
   expect yes/no { send yes\r ; exp_continue }
   expect password: { send "$1"\r }
   expect 100%
   sleep 1
   exit
"
}

tail -n +2 $FILE | while read LINE
do
    TMP=$(/bin/mktemp)
    USER=$(echo $LINE | awk '{print $1}')
    PW=$(echo $LINE | awk '{print $2}')
    HOST=$(echo $LINE | awk '{print $3}')
    echo -ne "$HOST\t\t" >> $LOG
    CMD $PW $USER $HOST > $TMP
    HOSTNAME=$(grep -vE 'password|spawn' $TMP)

    if [ ! abc$HOSTNAME = abc ]; then
        echo -e "$HOST\t\t$HOSTNAME" >> $LOG
    else
        echo -e "$HOST\t\tSomething went wrong. Cannot connect to host. Check connection or credentials" >> $LOG
    fi

    rm -f $TMP
done
