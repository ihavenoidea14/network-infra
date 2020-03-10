resource "aws_subnet" "subnet" {
  vpc_id = "${var.vpcId}"
  cidr_block = "${var.cidrBlock}"
  map_public_ip_on_launch = "${var.assign_public_ip}"
  availability_zone = "${var.az}"

  tags {
    Name = "${var.name}"
    VPC = "${var.vpcId}"
    Tier = "${var.tier}"
  }
}