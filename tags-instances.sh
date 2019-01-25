#!/bin/bash

#Stores required regions in an array
region=("eu-west-3" "ap-southeast-1")


for i in ${region[@]};
do
#AWS CLI  command to get all tags details of each instance in a region 
aws ec2 describe-tags --region $i  --filters "Name=resource-type,Values=instance" | jq -r '.Tags[] | "\(.ResourceId)\t\(.Key)\t\(.Value)"'
done


#Output
#   <Instance ID> <Tag Key> <Tag Value>
