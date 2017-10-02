#
# Setup
#

terraform {
  required_version = "0.10.6"
}

provider "aws" {
  region  = "${var.region}"
  version = "~> 0.1"
}

provider "template" {
  version = "~> 0.1"
}

data "aws_subnet" "snet" {
  id = "${var.subnet_id}"
}

# Note - in my actual use case, there are quite a few bits of data
# pulled from terraform_remote_state into locals. I've added vars so
# others can run this, but left the locals in place.
locals {
  subnet_id        = "${var.subnet_id}"
  az               = "${data.aws_subnet.snet.availability_zone}"
  common_tags      = {
    terraform_issue = "TBD"
  }
}

#
# EC2 Instance
#

resource "aws_instance" "ecs-instance" {
  ami                         = "${var.ami_id}"
  subnet_id                   = "${local.subnet_id}"
  instance_type               = "${var.instance_type}"
  associate_public_ip_address = "true"
  vpc_security_group_ids      = []
  user_data                   = "${data.template_file.user_data.rendered}"

  root_block_device {
    volume_type           = "standard"
    volume_size           = "8"
    delete_on_termination = "true"
  }

  tags = "${merge(
    local.common_tags,
    map(
      "Name", "tf-issue-TBD"
    )
  )}"

  provisioner "local-exec" {
    when    = "destroy"
    command = "${path.module}/instance-destroy.sh '${aws_instance.ecs-instance.public_ip}' '${var.persistent_ebs_mountpoint}'"
  }

}

output "instance_id" {
  value = "${aws_instance.ecs-instance.id}"
}

output "instance_private_ip" {
  value = "${aws_instance.ecs-instance.private_ip}"
}

output "instance_public_ip" {
  value = "${aws_instance.ecs-instance.public_ip}"
}

#
# User-Data
#

data "template_file" "user_data" {
  template = "${file("${path.module}/user_data.sh.tpl")}"

  vars {
    cloudwatch_prefix          = ""
    persistent_ebs_device_name = "${var.persistent_ebs_device_name}"
    persistent_ebs_mountpoint  = "${var.persistent_ebs_mountpoint}"
    something_that_changes     = "${var.something_that_changes}"
  }
}

#
# Volume Attachment
#

resource "aws_volume_attachment" "ecs-instance-persistent-vol-att" {
  device_name = "${var.persistent_ebs_device_name}"
  volume_id   = "${aws_ebs_volume.ecs-instance-persistent-vol.id}"
  instance_id = "${aws_instance.ecs-instance.id}"
}

#
# Persistent EBS Volume
#

resource "aws_ebs_volume" "ecs-instance-persistent-vol" {
  availability_zone = "${local.az}"
  type              = "standard"
  size              = "1" # GB

  tags = "${merge(
    local.common_tags,
    map(
      "Name", "tf-issue-TBD"
    )
  )}"
}

output "ebs_persistent_volume_id" {
  value = "${aws_ebs_volume.ecs-instance-persistent-vol.id}"
}

output "ebs_persistent_volume_device_name" {
  value = "${aws_ebs_volume.ecs-instance-persistent-vol.device_name}"
}

#
# Variables
#

variable "region" {
  description = "AWS region"
  type        = "string"
}

variable "subnet_id" {
  description = "subnet ID to deploy into"
  type        = "string"
}

variable "ami_id" {
  description = "AMI ID to use for ECS host"
  type        = "string"
  default     = "ami-1d668865" # us-west-2 amzn-ami-2017.03.f-amazon-ecs-optimized
}

variable "instance_type" {
  description = "EC2 Instance Type for ECS instance"
  type        = "string"
  default     = "t2.micro"
}

variable "persistent_ebs_mountpoint" {
  description = "Mountpoint of persistent EBS volume"
  type        = "string"
  default     = "/persistent"
}

variable "persistent_ebs_device_name" {
  description = "Device name of persistent EBS volume attachment"
  type        = "string"
  default     = "/dev/sdf"
}

variable "something_that_changes" {
  description = "Something in userdata that changes"
  type        = "string"
  default     = "foobar"
}
