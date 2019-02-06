 #!/bin/bash

usage(){
cat << EOF
Usage
Usecase: To share private AMI across AWS account.
If you want to own that private AMI shared by other AWS account make sure to perform Copy-AMI operation on that AMI .
transfer [-a] <AWS Account ID> [-i] <AMI ID>
		a - to pass AWS account ID
		i - to pass AMI ID
		h - help
                u - Usage

Copy image you can use the following command

aws ec2 copy-image --source-image-id ami-5731123e --source-region us-east-1 --region ap-northeast-1 --name "My server"
Copy AMI operation can be performed to the same region also

EOF
}

while getopts a:i:hu options; do
	case $options in 
 	a) account_id=$OPTARG
		;;
	i) image_id=$OPTARG
	   #Get ami associated sanpshot_id 
           snapshot_id=$(aws ec2 describe-images --image-ids $image_id   | jq -r ' .Images| .[] | .BlockDeviceMappings | .[].Ebs| .SnapshotId  ')
		;;
	h) usage 
		;;
	u) usage 
		;;
	?) echo"You are doing it wrong, try transfer -h to know the usage";
                ;; 
	esac
done

if [ -z "$account_id"  ] || [ -z "$image_id"  ]
then
      echo "Insufficent variables "
else
#To provide lauch access for another account . 
aws ec2 modify-image-attribute --image-id $image_id --launch-permission "Add=[{UserId=$account_id}]"
#To provide create volume permission for ami associated sanpshot
aws ec2 modify-snapshot-attribute --snapshot-id $snapshot_id --attribute createVolumePermission --operation-type add --user-ids $account_id
fi

