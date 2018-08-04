resource "aws_instance" "instance" {
  ami = "${var.ami}"
  instance_type = "${var.type}"
  subnet_id = "${var.subnetId}"
  vpc_security_group_ids = ["${var.securityGroups}"]
  source_dest_check = "${var.sourceDestCheck}"
  key_name = "${var.keyPair}"

  tags {
    Name = "${var.name}"
  }
}