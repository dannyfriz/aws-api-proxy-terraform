# Configuración del proveedor de AWS
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.4.0"
    }
  }

  required_version = ">= 1.5.0"
}

# Proveedor de AWS
provider "aws" {
  region = var.aws_region
}

# Variables
variable "api_uri" {}
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
variable "waf_acl_name" {}
variable "waf_acl_description" {}
variable "waf_rule_group_arn" {}
variable "api_gateway_api_domain_name" {}
variable "api_gateway_acm_certificate" {}
variable "proxy_lambda_function_name" {}
variable "proxy_lambda_runtime" {}
variable "proxy_lambda_handler" {}
variable "proxy_lambda_timeout" {}
variable "proxy_lambda_memory_size" {}
variable "proxy_function_code_path" {}

# Módulo: api_gateway
module "api_gateway" {
  source                          = "./modules/api_gateway"
  api_gateway_api_domain_name     = var.api_gateway_api_domain_name
  api_gateway_acm_certificate     = var.api_gateway_acm_certificate
  api_uri                         = var.api_uri
  api_description                 = var.api_description
  api_name                        = var.api_name
  api_stage_name                  = var.api_stage_name
  aws_account_id                  = var.aws_account_id
  aws_region                      = var.aws_region
  cloudwatch_log_group_arn        = module.cloudwatch.cloudwatch_log_group_arn
  lambda_function_arn             = module.lambda_function.lambda_function_arn
  lambda_function_name            = module.lambda_function.lambda_function_name
  api_gateway_cloudwatch_role_arn = module.iam.api_gateway_cloudwatch_role_arn
  proxy_function_arn              = module.lambda_function.proxy_function_arn
  proxy_function_name             = module.lambda_function.proxy_function_name
}

# Módulo: cloudwatch
module "cloudwatch" {
  source         = "./modules/cloudwatch"
  api_name       = var.api_name
  aws_account_id = var.aws_account_id
  aws_region     = var.aws_region
}

# Módulo: iam
module "iam" {
  source = "./modules/iam"
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
  dynamodb_table_arn         = module.dynamodb.dynamodb_table_arn
  dynamodb_table_name        = module.dynamodb.dynamodb_table_name
  proxy_lambda_function_name = var.proxy_lambda_function_name
  proxy_lambda_runtime = var.proxy_lambda_runtime
  proxy_lambda_handler = var.proxy_lambda_handler
  proxy_lambda_timeout = var.proxy_lambda_timeout
  proxy_lambda_memory_size = var.proxy_lambda_memory_size
  proxy_function_code_path = var.proxy_function_code_path
  api_uri                   = var.api_uri
}

# Módulo: dynamodb
module "dynamodb" {
  source                  = "./modules/dynamodb"
  dynamodb_billing_mode   = var.dynamodb_billing_mode
  dynamodb_read_capacity  = var.dynamodb_read_capacity
  dynamodb_table_name     = var.dynamodb_table_name
  dynamodb_write_capacity = var.dynamodb_write_capacity
}

# Módulo: waf
module "waf" {
  source                      = "./modules/waf"
  waf_acl_name                = var.waf_acl_name
  waf_acl_description         = var.waf_acl_description
  waf_rule_group_arn          = var.waf_rule_group_arn
  api_gateway_api_domain_name = var.api_gateway_api_domain_name
  api_gateway_stage_arn       = module.api_gateway.api_gateway_stage_arn

  depends_on = [module.api_gateway]
}