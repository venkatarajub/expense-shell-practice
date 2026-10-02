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
CHECK_ROOT
dnf install mysql-server -y &>> $LOG_FILE
VALIDATE $? "install mysql-server"
systemctl enable mysqld &>> $LOG_FILE
VALIDATE $? "enable mysqld"
systemctl start mysqld &>> $LOG_FILE
VALIDATE $? "start mysqld"

mysql -h mysql.venra.online -u root -pExpenseApp@1 -e 'show databases'; &>> $LOG_FILE
if [ $? -ne 0 ]
then
    echo -e "$Y mysql root password is not. setting $N" &>> $LOG_FILE
    mysql_secure_installation --set-root-pass ExpenseApp@1 &>> $LOG_FILE
    VALIDATE $? "setting mysql root password"
else
    echo -e "$G Mysql root password already set $N $Y skipping $N"
fi 