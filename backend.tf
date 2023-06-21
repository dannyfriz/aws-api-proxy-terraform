terraform {
  backend "s3" {
    bucket         = "terraform-api-proxy-state"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}