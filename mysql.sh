#!/bib/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/expense"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME-$TIMESTAMP.log"
USERID=$(id -u)
mkdir -p /var/log/expense
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
        echo -e "$R $2 failed. Pls checke $N" | tee -a $LOG_FILE
        exit
    else
        echo -e "$G $2 success $N " | tee -a $LOG_FILE
    fi
}
dnf list installed mysql
if [ $? -ne 0 ]
then
    dnf install mysql -y >> $LOG_FILE
    VALIDATE $? "install mysql"
else
    echo -e "$G Mysal already installed nothing to do. $N" | tee -a $LOG_FILE
fi
