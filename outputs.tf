output "lambda-subnet-prod" {
  value = "${module.lambda-subnet-prod.subnetId}"
}

output "lambda-subnet-dev" {
  value = "${module.lambda-subnet-dev.subnetId}"
}