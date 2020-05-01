#!/bin/bash

STACK_NAME=${1:-"philter"}

# SET YOUR SSH KEY NAME.
SSH_KEY_NAME=""

if [ -z "$SSH_KEY_NAME" ]
then
  echo "An SSH key name is required. Edit this script to set the key name."
  exit 1
fi

aws cloudformation create-stack \
  --stack-name $STACK_NAME \
  --template-body file://./philter-vpc-load-balanced-with-redis.json \
  --capabilities CAPABILITY_IAM \
  --parameters \
      ParameterKey=KeyName,ParameterValue="$SSH_KEY_NAME" \
      ParameterKey=FilterProfilesBucketName,ParameterValue="$STACK_NAME-filter-profiles" \
      ParameterKey=CreateBastionInstance,ParameterValue=false
