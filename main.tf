# Configuración del proveedor de AWS
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.64.0"
    }
  }

  required_version = ">= 1.4.5"

}

provider "aws" {
  region = var.region
}

module "api_gateway" {
  source = "./modules/api_gateway"

  # Variables específicas del módulo
  # ...
}

module "lambda_function" {
  source = "./modules/lambda_function"

  # Variables específicas del módulo
  # ...
}

module "dynamodb" {
  source = "./modules/dynamodb"

  # Variables específicas del módulo
  # ...
}
