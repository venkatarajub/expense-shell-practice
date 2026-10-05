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

dnf module disable nodejs -y &>> $LOG_FILE
VALIDATE $? "disabling nodejs"

dnf module enable nodejs:24 -y &>> $LOG_FILE
VALIDATE $? "enabling nodejs"

dnf install nodejs -y &>> $LOG_FILE
VALIDATE $? "installing nodejs"

mkdir -p /app
VALIDATE $? "app dir creating"

id expense
    if [ $? -ne 0 ]
    then
        useradd --system --home /app --shell /sbin/nologin --comment "expense system user" expense
        VALIDATE $? "Add expense user"
    else
        echo -e "expense user already created.. $Y SKIPPING $N" | tee -a $LOG_FILE
    fi

curl -o /tmp/backend.tar.gz https://raw.githubusercontent.com/daws-92s/expense-documentation/refs/heads/main/artifacts/expense-backend-v5.tar.gz &>> $LOG_FILE
VALIDATE $? "Downloading backend code"

cd /app
rm -rf /app/*
tar -xzf /tmp/backend.tar.gz &>> $LOG_FILE
VALIDATE $? "Extracting backend code"

cd /app
npm install
VALIDATE $? "npm instalation"

# cp -R /home/ec2-user/expense-shell-practice/backend.service /etc/systemd/system/backend.service $>> $LOG_FILE
# VALIDATE $? "copy backend service"

dnf install mysql -y &>> $LOG_FILE
VALIDATE $? "MYSQL client"

mysql -h <MYSQL-SERVER-IPADDRESS> -u root -pExpenseApp@1 < /app/schema/backend.sql
VALIDATE $? "scheama loading"

systemctl daemon-reload
VALIDATE $? "daemon reload"

systemctl enable backend
VALIDATE $? "backend enabled"

systemctl start backend
VALIDATE $? "backend restart"