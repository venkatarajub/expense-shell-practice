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

dnf install nginx -y &>> $LOG_FILE
VALIDATE $? "install nginx"

systemctl enable nginx &>> $LOG_FILE
VALIDATE $? "enabiling nginx"

systemctl start nginx &>> $LOG_FILE
VALIDATE $? "start nginx"

rm -rf /usr/share/nginx/html/* &>> $LOG_FILE
VALIDATE $? "Delete existing content in html"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>> $LOG_FILE
VALIDATE $? "Downloading fronr end code"

cd /usr/share/nginx/html
unzip /tmp/frontend.zip &>> $LOG_FILE
VALIDATE $? "unziping code"

cp /home/ec2-user/expense-shell-practice/expense.conf /etc/nginx/default.d/expense.conf &>> $LOG_FILE
VALIDATE $? "copying expense conf"

systemctl restart nginx
VALIDATE $? "restaring nginx"