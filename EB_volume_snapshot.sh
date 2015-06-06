#!/bin/bash
### Created 04/20/2015
### Script located on util.blue.process.prod under the "Deploy" account home folder
### Does require a folder be created under the account if instance is rebuilt

## EC2 access only. Unable to grant granular access as describe instance action not supported
## http://docs.aws.amazon.com/AWSEC2/latest/APIReference/ec2-api-permissions.html

## have to add AWS keys here with the correct permissions
export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=

### Locate the Instance information from AWS Elastic Beanstalk for
### Daisy Prod instance and output it a a file in json format ###
aws ec2 describe-tags --filters Name=resource-type,Values=instance \
Name=value,Values=daisy-prod-2 Name=key,Values=Name \
--query 'Tags[0]. {InstanceId:ResourceId}' > ~/daisy_snapshot/instance_info0.json


## Use the output of query above as the "Instance" input to get "Volume" information.
## In addition, remove information on root volume (/) and only output the second volume id as variable##

volinfo="$(aws ec2 describe-instance-attribute --cli-input-json file://daisy_snapshot/instance_info0.json \
--attribute blockDeviceMapping --query 'BlockDeviceMappings' \
|sed '2,5d'|sed '3,4d' |grep 'vol-' |sed -e 's/\"//g;s/\,//g;s/\VolumeId://g')"

## Pass variable to volume-id to create snapshot and write results out to a file.  The file will have the 'Snapshot-Id'
aws ec2 create-snapshot --volume-id $volinfo --description "Daisy Prod 2 Snapshots " >> ~/daisy_snapshot/snapshot_result_info

