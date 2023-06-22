# Terraform provider configuration for AWS
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.4.0"
    }
  }

  required_version = ">= 1.5.0"
}

# AWS provider configuration
provider "aws" {
  region = var.aws_region
}

# Variables
variable "api_description" {}
variable "api_gateway_acm_certificate" {}
variable "api_gateway_api_domain_name" {}
variable "api_name" {}
variable "api_stage_name" {}
variable "api_uri" {}
variable "aws_account_id" {}
variable "aws_region" {}
variable "dashboard_name" {}
variable "environment" {}
variable "name" {}
variable "project" {}
variable "proxy_function_code_path" {}
variable "proxy_lambda_function_name" {}
variable "proxy_lambda_handler" {}
variable "proxy_lambda_memory_size" {}
variable "proxy_lambda_runtime" {}
variable "proxy_lambda_timeout" {}
variable "waf_acl_description" {}
variable "waf_acl_name" {}

# Module: api_gateway
module "api_gateway" {
  source                          = "./modules/api_gateway"
  api_description                 = var.api_description
  api_gateway_acm_certificate     = var.api_gateway_acm_certificate
  api_gateway_api_domain_name     = var.api_gateway_api_domain_name
  api_name                        = var.api_name
  api_stage_name                  = var.api_stage_name
  api_uri                         = var.api_uri
  aws_account_id                  = var.aws_account_id
  aws_region                      = var.aws_region
  cloudwatch_log_group_arn        = module.cloudwatch.cloudwatch_log_group_arn
  api_gateway_cloudwatch_role_arn = module.iam.api_gateway_cloudwatch_role_arn
  proxy_function_arn              = module.lambda_function.proxy_function_arn
  proxy_function_name             = module.lambda_function.proxy_function_name
  environment                     = var.environment
  name                            = var.name
  project                         = var.project
}

# Module: cloudwatch
module "cloudwatch" {
  source         = "./modules/cloudwatch"
  api_name       = var.api_name
  aws_account_id = var.aws_account_id
  aws_region     = var.aws_region
}

# Module: dashboard
module "dashboard" {
  source                = "./modules/dashboard"
  api_id                = module.api_gateway.api_id
  dashboard_name        = var.dashboard_name
  lambda_function_name  = module.lambda_function.proxy_function_name
}

# Module: iam
module "iam" {
  source = "./modules/iam"
  environment                = var.environment
  name                       = var.name
  project                    = var.project
}

# Module: lambda_function
module "lambda_function" {
  source                     = "./modules/lambda_function"
  api_gateway_deployment_arn = module.api_gateway.api_gateway_deployment_arn
  api_uri                    = var.api_uri
  aws_region                 = var.aws_region
  environment                = var.environment
  name                       = var.name
  project                    = var.project
  proxy_function_code_path   = var.proxy_function_code_path
  proxy_lambda_function_name = var.proxy_lambda_function_name
  proxy_lambda_handler       = var.proxy_lambda_handler
  proxy_lambda_memory_size   = var.proxy_lambda_memory_size
  proxy_lambda_runtime       = var.proxy_lambda_runtime
  proxy_lambda_timeout       = var.proxy_lambda_timeout
}

# Module: waf
module "waf" {
  source                      = "./modules/waf"
  api_gateway_api_domain_name = var.api_gateway_api_domain_name
  api_gateway_stage_arn       = module.api_gateway.api_gateway_stage_arn
  waf_acl_description         = var.waf_acl_description
  waf_acl_name                = var.waf_acl_name
  depends_on                  = [module.api_gateway]
}
