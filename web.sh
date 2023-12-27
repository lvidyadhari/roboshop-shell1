#!/bin/bash
ID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"


LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script started and exicuted at $TIMESTAMP" &>> $LOGFILE

validate(){
     if [ $1 -ne 0 ]
    then
     echo  -e  "Error :: $2......  $R FAILED $N"
     exit 1
    else
     echo  -e  "$2..... $G success $N"
    fi
}


if [ $ID -ne 0 ]
then
    echo -e " Error:: $R stop the script and run with root access $N"
    exit 1
else
    echo -e  " you are root user"
fi


dnf install nginx -y         &>> $LOGFILE

validate $? "install nginx"

systemctl enable nginx      &>> $LOGFILE

validate $? "enable nginx"

systemctl start nginx     &>> $LOGFILE

validate $? "start  nginx"

rm -rf /usr/share/nginx/html/* &>> $LOGFILE

validate $? "removing default nginx "

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip  &>> $LOGFILE

validate $? "download web "

cd /usr/share/nginx/html &>> $LOGFILE

validate $? "change directory "

unzip -o /tmp/web.zip  &>> $LOGFILE

validate $? "unzip "

cp /home/centos/roboshop-shell1/roboshop.conf  /etc/nginx/default.d/roboshop.conf   &>> $LOGFILE

validate $? "copying roboshopconf file "

systemctl restart nginx 

validate $? "restarting nginx "