terraform {
  required_version = ">= 1.0"
  
  backend "s3" {
    bucket         = "nombre-del-bucket-s3"
    key            = "ruta-dentro-del-bucket/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "nombre-de-la-tabla-dynamodb"
    profile        = "nombre-del-perfil-de-credenciales"
  }
}

provider "aws" {
  region = var.aws_region
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
