data "aws_subnet_ids" "selected" {
  vpc_id = "${data.aws_vpc.selected.id}"
}

data "aws_vpc" "selected" {
  id = "${var.vpc_id}"
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