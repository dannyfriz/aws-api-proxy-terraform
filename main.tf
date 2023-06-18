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

# Carga los valores de las variables del archivo .tfvars de uso global
variable "region" {}
variable "api_name" {}
variable "api_description" {}
variable "api_stage_name" {}
variable "dynamodb_table_name" {}
variable "dynamodb_billing_mode" {}
variable "dynamodb_read_capacity" {}
variable "dynamodb_write_capacity" {}
variable "lambda_function_name" {}
variable "lambda_runtime" {}
variable "lambda_handler" {}
variable "lambda_timeout" {}
variable "lambda_memory_size" {}
variable "lambda_function_code_path" {}
variable "account_id" {}

# Carga los valores de las variables del archivo .tfvars como variables locales
locals {
  region                    = var.region
  account_id                = var.account_id
  api_name                  = var.api_name
  api_description           = var.api_description
  api_stage_name            = var.api_stage_name
  dynamodb_table_name       = var.dynamodb_table_name
  dynamodb_billing_mode     = var.dynamodb_billing_mode
  dynamodb_read_capacity    = var.dynamodb_read_capacity
  dynamodb_write_capacity   = var.dynamodb_write_capacity
  lambda_function_name      = var.lambda_function_name
  lambda_runtime            = var.lambda_runtime
  lambda_handler            = var.lambda_handler
  lambda_timeout            = var.lambda_timeout
  lambda_memory_size        = var.lambda_memory_size
  lambda_function_code_path = var.lambda_function_code_path
}

module "api_gateway" {
  source = "./modules/api_gateway"
  api_name         = var.api_name
  api_description  = var.api_description
  api_stage_name   = var.api_stage_name
  region           = var.region
  account_id       = var.account_id
  lambda_function_arn = module.lambda_function.lambda_function_arn
}

module "lambda_function" {
  source             = "./modules/lambda_function"
  lambda_function_name      = var.lambda_function_name
  lambda_runtime            = var.lambda_runtime
  lambda_handler            = var.lambda_handler
  lambda_timeout            = var.lambda_timeout
  lambda_memory_size        = var.lambda_memory_size
  lambda_function_code_path = var.lambda_function_code_path
  api_gateway_arn           = module.api_gateway.api_gateway_arn
  region                    = var.region
}

module "dynamodb" {
  source = "./modules/dynamodb"
  dynamodb_table_name      = var.dynamodb_table_name
  dynamodb_billing_mode    = var.dynamodb_billing_mode
  dynamodb_read_capacity   = var.dynamodb_read_capacity
  dynamodb_write_capacity  = var.dynamodb_write_capacity
}
