terraform {
  backend "s3" {
    bucket = "capstone-eks-tfstate"
    region = "us-east-2"
    key    = "capstone/terraform.tfstate"
  }
}
