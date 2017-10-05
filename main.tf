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

# Note - in my actual use case, there are quite a few bits of data
# pulled from terraform_remote_state into locals. I've added vars so
# others can run this, but left the locals in place.
locals {
  subnet_id        = "${var.subnet_id}"
  common_tags      = {
    terraform_issue = "16237"
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
      "Name", "tf-issue-16237"
    )
  )}"

  provisioner "local-exec" {
    when    = "destroy"
    command = "${path.module}/instance-destroy.sh '${aws_instance.ecs-instance.public_ip}'"
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
    something_that_changes     = "${var.something_that_changes}"
  }
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
  default     = "ami-e689729e" # us-west-2 Amazon Linux 2017.09.0.20170930 HVM
}

variable "instance_type" {
  description = "EC2 Instance Type for ECS instance"
  type        = "string"
  default     = "t2.micro"
}

variable "something_that_changes" {
  description = "Something in userdata that changes"
  type        = "string"
  default     = "foobar"
}
