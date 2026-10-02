#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS-FOLDER="/var/log/expense"
SCRIPT-NAME=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG-FILE=$LOGS-FOLDER/$SCRIPT-NAME-$TIMESTAMP.log
mkdir -p $LOGS-FOLDER

USERID=$(id -u)
CHECK_ROOT(){
    if [ $USERID -ne 0 ]
    then
        echo -e "$Y Run the script with root access $N"
        exit 1
    fi
}

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 .. is $R FAILED $N. pls check"
        exit 1
    else 
        echo -e "$2 .. is $G SUCESS $N"
    fi
}

echo "Script executed time: $date"

dnf list installed mysql

dnf install mysql-server -y
VALIDATE $? "Installing mysql server"

systemctl enable mysqld
VALIDATE $? "enablening mysqld"

systemctl start mysqld
VALIDATE $? "Starting mysqld"
