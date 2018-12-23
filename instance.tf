# Create a new EC2 instance of the latest Ubuntu 14.04 on an
# t2.micro node with an AWS tag naming it "Devbox"

variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_region" {}
variable "public_key" {}
variable "vpc_id" {}
output "region" {
  value = "${var.aws_region}"
}
provider "aws" {
  region     = "${var.aws_region}"
}
data "aws_vpc" "selected" {
  id = "${var.vpc_id}"
  # enable_dns_hostnames = true
}
data "aws_subnet_ids" "selected" {
  vpc_id = "${data.aws_vpc.selected.id}"
}
resource "aws_eip" "instance" {
    vpc = true
    instance  = "${aws_instance.devbox.id}"
}
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "${var.public_key}"
}
resource "aws_security_group" "security_group_ingress_egress" {
  name        = "security_group_ingress_egress"
  description = "Allow ssh mosh udp http test and egress all"
  vpc_id = "${data.aws_vpc.selected.id}"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 60000
    to_port     = 61000
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port       = 0
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  ingress {
    from_port       = 0
    to_port         = 8080
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  tags {
    Name = "EC2 Instance"
    group = "instance"
  }
}
resource "aws_instance" "devbox" {
  count = 1
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.deployer.key_name}"
  vpc_security_group_ids = ["${aws_security_group.security_group_ingress_egress.id}"]
  subnet_id = "${element(concat(data.aws_subnet_ids.selected.ids), count.index)}"
  tags = {
    Name = "Devbox"
    Group = "dev"
  }
}
output "aws_instance_id" {
  value = "${aws_instance.devbox.id}"
}
output "instance_public_ip" {
  value = "${aws_eip.instance.public_ip}"
}
output "instance_private_ip" {
  value = "${aws_eip.instance.private_ip}"
}
output "aws_instance_availability_zone" {
  value = "${aws_instance.devbox.availability_zone}"
}
output "aws_instance_subnet_id" {
  value = "${aws_instance.devbox.subnet_id}"
}
output "aws_instance_vpc_id" {
  value = "${var.vpc_id}"
}
output "ssh" {
  value = "ssh ubuntu@${aws_eip.instance.public_ip}"
}

