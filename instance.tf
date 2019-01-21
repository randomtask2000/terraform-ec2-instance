# Create a new EC2 instance of the latest Ubuntu 14.04 on an
# t2.micro node with an AWS tag naming it "Devbox"

provider "aws" {
  region     = "${var.aws_region}"
}

resource "aws_eip" "instance" {
    vpc = true
    instance  = "${aws_instance.devbox.id}"
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
  iam_instance_profile = "${aws_iam_instance_profile.test_profile.name}"
  user_data = "${element(data.template_file.arep_config.*.rendered, count.index)}"
  tags = {
    Name = "Devbox"
    Group = "dev"
  }
}

data "template_file" "arep_config" {
  template = "${file("init.sh")}"
}