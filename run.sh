#!/bin/bash -x

if [ -z "$AWS_REGION" ]; then echo "ERROR: please export AWS_REGION"; exit 1; fi
if [ -z "$SUBNET_ID" ]; then echo "ERROR: please export SUBNET_ID"; exit 1; fi

VARS="-var region=${AWS_REGION} -var subnet_id=${SUBNET_ID}"
terraform init
  terraform plan $VARS .
terraform apply -auto-approve=true $VARS .
sleep 120
terraform plan -var 'something_that_changes=bazblam' $VARS .
terraform apply -var 'something_that_changes=bazblam' -auto-approve=true $VARS .
echo "OK. Destroying."
terraform destroy -force $VARS .
