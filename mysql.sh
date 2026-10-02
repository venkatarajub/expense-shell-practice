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

dnf list installed mysql

dnf install mysql-server -y &>> $LOG_FILE
VALIDATE $? "Installing mysql server"

systemctl enable mysqld &>> $LOG_FILE
VALIDATE $? "enablening mysqld"

systemctl start mysqld &>> $LOG_FILE
VALIDATE $? "Starting mysqld"
