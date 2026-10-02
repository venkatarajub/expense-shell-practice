#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/expense"
mkdir -p $LOGS_FOLDER
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME-$TIMESTAMP.log"

USERID=$(id -u)

CHECK_ROOT(){
    if [ $USERID -ne 0 ]
    then
        echo -e "$Y Run the script with root access $N" | tee -a $LOG_FILE
        exit 1
    fi
}

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 .. is $R FAILED $N. pls check" | tee -a $LOG_FILE
        exit 1
    else 
        echo -e "$2 .. is $G SUCESS $N" | tee -a $LOG_FILE
    fi
}

CHECK_ROOT

echo "Script executed time: $(date)"

dnf module disable nodejs -y
VALIDATE $? "disabling nodejs"

dnf module enable nodejs:20 -y
VALIDATE $? "enabling nodejs"

dnf install nodejs -y
VALIDATE $? "installing nodejs"
