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
variable "api_uri" {}
variable "api_description" {}
variable "api_name" {}
variable "api_stage_name" {}
variable "aws_account_id" {}
variable "aws_region" {}
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
variable "name" {}
variable "project" {}
variable "environment" {}
variable "dashboard_name" {}

# Module: api_gateway
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
  api_gateway_cloudwatch_role_arn = module.iam.api_gateway_cloudwatch_role_arn
  proxy_function_arn              = module.lambda_function.proxy_function_arn
  proxy_function_name             = module.lambda_function.proxy_function_name
  name = var.name 
  project  = var.project
  environment = var.environment
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
  source         = "./modules/dashboard"
  api_id       = module.api_gateway.api_id
  lambda_function_name =module.lambda_function.proxy_function_name
  dashboard_name  = var.dashboard_name
}


# Module: iam
module "iam" {
  source = "./modules/iam"
}

# Module: lambda_function
module "lambda_function" {
  source                     = "./modules/lambda_function"
  api_gateway_deployment_arn = module.api_gateway.api_gateway_deployment_arn
  aws_region                 = var.aws_region
  proxy_lambda_function_name = var.proxy_lambda_function_name
  proxy_lambda_runtime       = var.proxy_lambda_runtime
  proxy_lambda_handler       = var.proxy_lambda_handler
  proxy_lambda_timeout       = var.proxy_lambda_timeout
  proxy_lambda_memory_size   = var.proxy_lambda_memory_size
  proxy_function_code_path   = var.proxy_function_code_path
  api_uri                    = var.api_uri
}

# Module: waf
module "waf" {
  source                      = "./modules/waf"
  waf_acl_name                = var.waf_acl_name
  waf_acl_description         = var.waf_acl_description
  waf_rule_group_arn          = var.waf_rule_group_arn
  api_gateway_api_domain_name = var.api_gateway_api_domain_name
  api_gateway_stage_arn       = module.api_gateway.api_gateway_stage_arn

  depends_on = [module.api_gateway]
}
