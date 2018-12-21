# Create a new EC2 instance of the latest Ubuntu 14.04 on an
# t2.micro node with an AWS tag naming it "Devbox"

variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_region" {}
variable "public_key" {}
variable "vpc_id" {}

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

resource "aws_s3_bucket" "codebuild_bucket" {
  bucket = "randomtask2000-terraform-state"
  acl    = "private"
  tags = {
    group = "codebuild"
  }
}

resource "aws_iam_role" "codebuild_role" {
  name = "codebuild_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
  tags = {
    group = "codebuild"
  }
}

resource "aws_iam_role_policy" "codebuild_policy" {
  role = "${aws_iam_role.codebuild_role.name}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    },
    {
      "Effect": "Allow",
      "Action": ["ec2:*"],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "${aws_s3_bucket.codebuild_bucket.arn}",
        "${aws_s3_bucket.codebuild_bucket.arn}/*"
      ]
    }
  ]
}
POLICY
}

resource "aws_codebuild_project" "codebuild_project" {
  name          = "codebuild-project"
  description   = "Codebuild Project that builds a github repo"
  build_timeout = "15"
  service_role  = "${aws_iam_role.codebuild_role.arn}"

  artifacts {
    type = "NO_ARTIFACTS"
  }

  cache {
    type     = "S3"
    location = "${aws_s3_bucket.codebuild_bucket.bucket}"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    # image        = "aws/codebuild/nodejs:6.3.1"
    image        = "aws/codebuild/ubuntu-base:14.04"
    type         = "LINUX_CONTAINER"

    environment_variable {
      "name"  = "SOME_KEY1"
      "value" = "SOME_VALUE1"
    }

    environment_variable {
      "name"  = "SOME_KEY2"
      "value" = "SOME_VALUE2"
      "type"  = "PARAMETER_STORE"
    }
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/randomtask2000/terraform_ec2_instance.git"
    git_clone_depth = 1
  }

  vpc_config {
    vpc_id = "${data.aws_vpc.selected.id}"
    subnets = ["${data.aws_subnet_ids.selected.ids}"]
    security_group_ids = ["${aws_security_group.codebuild_allow_all.id}"]
  }

  tags = {
    group = "codebuild"
  }
}
resource "aws_security_group" "codebuild_allow_all" {
  name        = "codebuild_allow_all"
  description = "Allow all inbound traffic"
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
  egress {
    from_port       = 0
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  egress {
    from_port       = 0
    to_port         = 8080
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  tags {
    Name = "cloudbuild with ssh mosh udp http test"
    group = "cloudbuild"
  }
}
output "region" {
  value = "${var.aws_region}"
}
output "aws_instance_vpc_id" {
  value = "${var.vpc_id}"
}


