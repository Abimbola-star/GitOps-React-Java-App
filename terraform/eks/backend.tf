terraform {
  backend "s3" {
    bucket  = "abiaro-devs-eks"
    key     = "eks/terraform.state"
    region  = "us-east-1"
    dynamodb_table = "devops-tf-locks"
    encrypt = true
  }
}