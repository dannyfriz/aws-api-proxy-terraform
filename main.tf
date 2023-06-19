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

# Proveedor de AWS
provider "aws" {
  region = var.aws_region
}

# Variables
variable "api_description" {}
variable "api_name" {}
variable "api_stage_name" {}
variable "aws_account_id" {}
variable "aws_region" {}
variable "dynamodb_billing_mode" {}
variable "dynamodb_read_capacity" {}
variable "dynamodb_table_name" {}
variable "dynamodb_write_capacity" {}
variable "lambda_function_code_path" {}
variable "lambda_function_name" {}
variable "lambda_handler" {}
variable "lambda_memory_size" {}
variable "lambda_runtime" {}
variable "lambda_timeout" {}

# Módulo: api_gateway
module "api_gateway" {
  source                    = "./modules/api_gateway"
  api_description           = var.api_description
  api_name                  = var.api_name
  api_stage_name            = var.api_stage_name
  aws_account_id            = var.aws_account_id
  aws_region                = var.aws_region
  cloudwatch_log_group_arn  = module.cloudwatch.cloudwatch_log_group_arn
  lambda_function_arn       = module.lambda_function.lambda_function_arn
  lambda_function_name      = module.lambda_function.lambda_function_name
}

# Módulo: cloudwatch
module "cloudwatch" {
  source                 = "./modules/cloudwatch"
  api_name               = var.api_name
  aws_account_id         = var.aws_account_id
  aws_region             = var.aws_region
}

# Módulo: lambda_function
module "lambda_function" {
  source                     = "./modules/lambda_function"
  api_gateway_deployment_arn = module.api_gateway.api_gateway_deployment_arn
  aws_region                 = var.aws_region
  lambda_function_code_path  = var.lambda_function_code_path
  lambda_function_name       = var.lambda_function_name
  lambda_handler             = var.lambda_handler
  lambda_memory_size         = var.lambda_memory_size
  lambda_runtime             = var.lambda_runtime
  lambda_timeout             = var.lambda_timeout
}

# Módulo: dynamodb
module "dynamodb" {
  source                   = "./modules/dynamodb"
  dynamodb_billing_mode    = var.dynamodb_billing_mode
  dynamodb_read_capacity   = var.dynamodb_read_capacity
  dynamodb_table_name      = var.dynamodb_table_name
  dynamodb_write_capacity  = var.dynamodb_write_capacity
}
