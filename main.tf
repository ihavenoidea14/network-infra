provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "wade-vpc" {
  cidr_block = "192.168.0.0/16"

  tags {
    Name = "wade-vpc"
  }
}

resource "aws_internet_gateway" "wade-ig" {
  vpc_id = "${aws_vpc.wade-vpc.id}"

  tags {
    Name = "internet"
    VPC = "${aws_vpc.wade-vpc.id}"
  }
}

module "nat" {
  source = "./instances"
  ami = "ami-4c9e4b24",
  type = "t2.nano",
  subnetId = "${module.public-subnet-1.subnetId}"
  keyPair = "wade-aws"
  name = "NAT"
  securityGroups = ["${module.nat-sg.sgId}"]
  sourceDestCheck = false
}

module "jump" {
  source = "./instances"
  ami = "ami-657cf71a",
  type = "t2.nano",
  subnetId = "${module.public-subnet-1.subnetId}"
  keyPair = "wade-aws"
  name = "jump"
  securityGroups = ["${module.default-sg.sgId}"]
  sourceDestCheck = true
}

module "private" {
  source = "./instances"
  ami = "ami-657cf71a",
  type = "t2.nano",
  subnetId = "${module.private-subnet-1.subnetId}"
  keyPair = "wade-aws"
  name = "private"
  securityGroups = ["${module.default-sg.sgId}"]
  sourceDestCheck = true
}

module "nat-sg" {
  source = "./security-groups/nat"
  name = "nat-sg"
  vpcCidr = ["${aws_vpc.wade-vpc.cidr_block}"]
  vpcId = "${aws_vpc.wade-vpc.id}"
}

module "default-sg" {
  source = "./security-groups/default"
  name = "default-sg"
  vpcId = "${aws_vpc.wade-vpc.id}"
  vpcCidr = ["${aws_vpc.wade-vpc.cidr_block}"]
  myIp = ["70.160.81.79/32"]
}

module "private-subnet-1" {
  source = "./subnets"
  vpcId = "${aws_vpc.wade-vpc.id}"
  cidrBlock = "192.168.1.0/24"
  name = "private-subnet-1"
}

module "private-subnet-2" {
  source = "./subnets"
  vpcId = "${aws_vpc.wade-vpc.id}"
  cidrBlock = "192.168.2.0/24"
  name = "private-subnet-2"
}

module "public-subnet-1" {
  source = "./subnets"
  vpcId = "${aws_vpc.wade-vpc.id}"
  cidrBlock = "192.168.3.0/24"
  name = "public-subnet-1"
  assign_public_ip = true
}

resource "aws_route_table" "private-rt" {
  vpc_id = "${aws_vpc.wade-vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    instance_id = "${module.nat.instanceId}"
  }
}

resource "aws_route_table" "public-rt" {
  vpc_id = "${aws_vpc.wade-vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.wade-ig.id}"
  }
}

resource "aws_route_table_association" "private-rt-association-1" {
  subnet_id = "${module.private-subnet-1.subnetId}"
  route_table_id = "${aws_route_table.private-rt.id}"
}

resource "aws_route_table_association" "private-rt-association-2" {
  subnet_id = "${module.private-subnet-2.subnetId}"
  route_table_id = "${aws_route_table.private-rt.id}"
}

resource "aws_route_table_association" "public-rt-association" {
  subnet_id = "${module.public-subnet-1.subnetId}"
  route_table_id = "${aws_route_table.public-rt.id}"
}