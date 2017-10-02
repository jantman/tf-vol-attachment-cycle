#!/bin/bash

echo "PERSISTENT_EBS_DEVICE_NAME=${persistent_ebs_device_name}" >> /etc/userdata_vars.sh
echo "PERSISTENT_EBS_MOUNTPOINT=${persistent_ebs_mountpoint}" >> /etc/userdata_vars.sh
echo "SOMETHING_THAT_CHANGES=${something_that_changes}" >> /etc/userdata_vars.sh
echo "CLOUDWATCH_PREFIX=${cloudwatch_prefix}" >> /etc/userdata_vars.sh
