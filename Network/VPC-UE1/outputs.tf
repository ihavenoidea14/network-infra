output "lambda-subnet-prod" {
  value = "${module.lambda-subnet-prod.subnetId}"
}

output "lambda-subnet-dev" {
  value = "${module.lambda-subnet-dev.subnetId}"
}

output "jump-box-ip" {
  value = "${module.jump.public-ip-address}"
}

output "private-box-ip" {
  value = "${module.jump.private-ip-address}"
}
