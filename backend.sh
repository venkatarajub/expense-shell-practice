#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/expense"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE=$LOGS_FOLDER/$SCRIPT_NAME-$TIMESTAMP.log
mkdir -p $LOGS_FOLDER
USERID=$(id -u)

CHECK_ROOT(){
    if [ $USERID -ne 0 ]
    then
        echo -e "$Y Run the script with root access $N"
    fi
}

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 is $R FAILD $N .. Pls check"
    else
        echo -e "$2 is $G SUCCESS $N"
    fi
}

CHECK_ROOT

echo "Script start date:$(date)"

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "nodejs disabled"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "nodejs enabled"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Install nodejs"

id expense
    if [ $? -ne 0 ]
    then 
        echo -e "expense user not available creating"
        useradd expense
        VALIDATE $? "expense user created"
    fi
mkdir -p /app

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip
VALIDATE $? "downloading backend code"

cd /app
unzip /tmp/backend.zip
VALIDATE $? "Extracting backend code"

cd /app
npm install
VALIDATE $? "npm installed"

cp /home/ec2-user/expense-shell-practice/backend.service /etc/systemd/system/backend.service
VALIDATE $? "copy backend service"

dnf install mysql -y
VALIDATE $? "mysql client install"

mysql -h mysql.venra.online -uroot -pExpenseApp@1 < /app/schema/backend.sql
VALIDATE $? "Schema loading"

systemctl daemon-reload
VALIDATE $? "daemon reload"

systemctl enable backend
VALIDATE $? "Enabled backend"

systemctl restart backend
VALIDATE $? "restart backend"