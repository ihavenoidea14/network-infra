output "instanceId" {
  value = "${aws_instance.instance.id}"
}

output "public-ip-address" {
  value = "${aws_instance.instance.public_ip}"
}

output "private-ip-address" {
  value = "${aws_instance.instance.private_ip}"
}
