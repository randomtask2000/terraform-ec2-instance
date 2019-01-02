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
output "region" {
  value = "${var.aws_region}"
}
