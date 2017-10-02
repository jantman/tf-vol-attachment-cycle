#!/bin/bash -x
# This script is used to retry stopping all Docker containers and then
# cleanly unmounting the persistent EBS volume on destroy.
# We use local-exec so we can try N times and then fail silently, instead
# of terraform's remote-exec which can't ignore failures.
INST_IP=$1
MPOINT=$2
USER=ec2-user
PORT=22

exit 0
