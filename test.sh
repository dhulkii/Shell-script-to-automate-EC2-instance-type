#!/bin/bash

INSTANCE_ID="i-0d**********f4"
REGION="ap-northeast-1"
PEAK_INSTANCE_TYPE="t3.medium"
OFF_PEAK_INSTANCE_TYPE="t2.micro"


CURRENT_HOUR=$(TZ="America/New_York" date +%H)

if [ "$CURRENT_HOUR" -ge 5 ] && [ "$CURRENT_HOUR" -lt 23 ]; then
    NEW_INSTANCE_TYPE=$PEAK_INSTANCE_TYPE
else
    NEW_INSTANCE_TYPE=$OFF_PEAK_INSTANCE_TYPE
fi

CURRENT_INSTANCE_TYPE=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --region $REGION --query "Reservations[*].Instances[*].InstanceType" --output text)


if [ "$CURRENT_INSTANCE_TYPE" != "$NEW_INSTANCE_TYPE" ]; then
    echo "Current instance type: $CURRENT_INSTANCE_TYPE. Changing to: $NEW_INSTANCE_TYPE."


    echo "Stopping the instance: $INSTANCE_ID ..."
    aws ec2 stop-instances --instance-ids $INSTANCE_ID --region $REGION


    echo "Waiting for the instance to stop..."
    aws ec2 wait instance-stopped --instance-ids $INSTANCE_ID --region $REGION
    echo "Instance stopped successfully."


    echo "Modifying the instance type to $NEW_INSTANCE_TYPE..."
    aws ec2 modify-instance-attribute --instance-id $INSTANCE_ID --instance-type "{\"Value\": \"$NEW_INSTANCE_TYPE\"}" --region $REGION


    echo "Starting the instance: $INSTANCE_ID ..."
    aws ec2 start-instances --instance-ids $INSTANCE_ID --region $REGION


    echo "Waiting for the instance to start..."
    aws ec2 wait instance-running --instance-ids $INSTANCE_ID --region $REGION
    echo "Instance is running with the new type: $NEW_INSTANCE_TYPE"
else
    echo "No change needed. Instance is already of type: $CURRENT_INSTANCE_TYPE."
fi
