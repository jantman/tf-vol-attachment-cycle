#!/bin/bash

echo "SOMETHING_THAT_CHANGES=${something_that_changes}" >> /etc/userdata_vars.sh
echo "CLOUDWATCH_PREFIX=${cloudwatch_prefix}" >> /etc/userdata_vars.sh
