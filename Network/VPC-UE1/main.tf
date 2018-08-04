provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "vpc-ue1" {
  cidr_block = "192.168.0.0/16"

  tags {
    Name = "vpc-ue1"
  }
}

resource "aws_internet_gateway" "vpc-ue1-internet" {
  vpc_id = "${aws_vpc.vpc-ue1.id}"

  tags {
    Name = "internet"
    VPC = "${aws_vpc.vpc-ue1.id}"
  }
}

module "nat" {
  source = "../../EC2"
  ami = "ami-4c9e4b24",
  type = "t2.nano",
  subnetId = "${module.public-subnet-dev.subnetId}"
  keyPair = "wade-aws"
  name = "dev-NAT"
  securityGroups = ["${module.nat-sg.sgId}"]
  sourceDestCheck = false
}

module "jump" {
  source = "../../EC2"
  ami = "ami-657cf71a",
  type = "t2.nano",
  subnetId = "${module.public-subnet-dev.subnetId}"
  keyPair = "wade-aws"
  name = "jump"
  securityGroups = ["${module.default-sg.sgId}"]
  sourceDestCheck = true
}

module "private" {
  source = "../../EC2"
  ami = "ami-657cf71a",
  type = "t2.nano",
  subnetId = "${module.private-subnet-dev.subnetId}"
  keyPair = "wade-aws"
  name = "private"
  securityGroups = ["${module.default-sg.sgId}"]
  sourceDestCheck = true
}

module "nat-sg" {
  source = "../../SecurityGroups/nat"
  name = "nat-sg"
  vpcCidr = ["${aws_vpc.vpc-ue1.cidr_block}"]
  vpcId = "${aws_vpc.vpc-ue1.id}"
}

module "default-sg" {
  source = "../../SecurityGroups/default"
  name = "default-sg"
  vpcId = "${aws_vpc.vpc-ue1.id}"
  vpcCidr = ["${aws_vpc.vpc-ue1.cidr_block}"]
  myIp = ["70.160.81.79/32"]
}

module "private-subnet-prod" {
  source = "./Subnets"
  vpcId = "${aws_vpc.vpc-ue1.id}"
  cidrBlock = "192.168.1.0/24"
  name = "private-subnet-prod"
}

module "private-subnet-dev" {
  source = "./Subnets"
  vpcId = "${aws_vpc.vpc-ue1.id}"
  cidrBlock = "192.168.2.0/24"
  name = "private-subnet-dev"
}

module "lambda-subnet-dev" {
  source = "./Subnets"
  vpcId = "${aws_vpc.vpc-ue1.id}"
  cidrBlock = "192.168.5.0/24"
  name = "lambda-subnet-dev"
}

module "lambda-subnet-prod" {
  source = "./Subnets"
  vpcId = "${aws_vpc.vpc-ue1.id}"
  cidrBlock = "192.168.6.0/24"
  name = "lambda-subnet-prod"
}

module "public-subnet-prod" {
  source = "./Subnets"
  vpcId = "${aws_vpc.vpc-ue1.id}"
  cidrBlock = "192.168.3.0/24"
  name = "public-subnet-prod"
  assign_public_ip = true
}

module "public-subnet-dev" {
  source = "./Subnets"
  vpcId = "${aws_vpc.vpc-ue1.id}"
  cidrBlock = "192.168.4.0/24"
  name = "public-subnet-dev"
  assign_public_ip = true
}

resource "aws_route_table" "private-rt" {
  vpc_id = "${aws_vpc.vpc-ue1.id}"
  route {
    cidr_block = "0.0.0.0/0"
    instance_id = "${module.nat.instanceId}"
  }
}

resource "aws_route_table" "public-rt" {
  vpc_id = "${aws_vpc.vpc-ue1.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.vpc-ue1-internet.id}"
  }
}

resource "aws_route_table_association" "private-rt-association-prod" {
  subnet_id = "${module.private-subnet-prod.subnetId}"
  route_table_id = "${aws_route_table.private-rt.id}"
}

resource "aws_route_table_association" "private-rt-association-dev" {
  subnet_id = "${module.private-subnet-dev.subnetId}"
  route_table_id = "${aws_route_table.private-rt.id}"
}

resource "aws_route_table_association" "private-rt-association-lambda-dev" {
  subnet_id = "${module.lambda-subnet-dev.subnetId}"
  route_table_id = "${aws_route_table.private-rt.id}"
}

resource "aws_route_table_association" "private-rt-association-lambda-prod" {
  subnet_id = "${module.lambda-subnet-prod.subnetId}"
  route_table_id = "${aws_route_table.private-rt.id}"
}

resource "aws_route_table_association" "public-rt-association-prod" {
  subnet_id = "${module.public-subnet-prod.subnetId}"
  route_table_id = "${aws_route_table.public-rt.id}"
}

resource "aws_route_table_association" "public-rt-association-dev" {
  subnet_id = "${module.public-subnet-dev.subnetId}"
  route_table_id = "${aws_route_table.public-rt.id}"
}