#!/bin/bash

AMI=ami-03265a0778a880afb
SG_ID=sg-0edd3d40dafc99687
INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "web")
ZONE_ID=Z028577132BYH8QZFT8FZ # replace your zone ID
DOMAIN_NAME="daws76s.store"

for i in "${INSTANCES[@]}"
do 
  if [ $i == "mongodb" ] || [ $i == "mysql" ] || [ $i == "shipping" ]
  then 
       INSTANCE_TYPE="t3.small"
    else
       INSTANCE_TYPE="t2.micro"
    fi
    IP_ADDRESS=$(aws ec2 run-instances --image-id ami-03265a0778a880afb --instance-type $INSTANCE_TYPE  --security-group-ids sg-0edd3d40dafc99687 --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]"
    --query 'Instances[0].PrivateIpAddress' --output text)
    echo "$i: $IP_ADDRESS"

    #CREATE R53 record, make sure you delete existing record
    aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONE_ID \
    --change-batch "
    {
        "Comment": "Creating a record set for cognito endpoint"
        ,"Changes": [{
        "Action"              : "CREATE"
        ,"ResourceRecordSet"  : {
            "Name"              : "'$i'.'$DOMAIN_NAME'"
            ,"Type"             : "A"
            ,"TTL"              : 1
            ,"ResourceRecords"  : [{
                "Value"         : "'$IP_ADDRESS'"
            }]
        }
        }]
    }
    "
done
