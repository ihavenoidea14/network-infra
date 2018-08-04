variable "ami" {}

variable "type" {}

variable "subnetId" {}

variable "keyPair" {}

variable "name" {}

variable "securityGroups" {
  type = "list"
}

variable "sourceDestCheck" {
  type = "string"
}
