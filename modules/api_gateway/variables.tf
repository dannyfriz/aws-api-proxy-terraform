variable "api_name" {
  description = "Name of the API Gateway"
  type        = string
}

variable "api_description" {
  description = "Description of the API Gateway"
  type        = string
}

variable "api_stage_name" {
  description = "Name of the API Gateway stage"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
}

variable "cloudwatch_log_group_arn" {
  description = "CloudWatch log group ARN"
  type        = string
}

variable "api_uri" {
  description = "API Gateway domain URI"
  type        = string
}

variable "api_gateway_cloudwatch_role_arn" {
  description = "API Gateway CloudWatch role ARN"
  type        = string
}

variable "api_gateway_api_domain_name" {
  description = "API Gateway API domain name"
  type        = string
}

variable "api_gateway_acm_certificate" {
  description = "API Gateway ACM certificate"
  type        = string
}

variable "proxy_function_arn" {
  description = "Proxy function ARN"
  type        = string
}

variable "proxy_function_name" {
  description = "Proxy function name"
  type        = string
}

variable "name" {
  description = "Name"
  type        = string
}

variable "project" {
  description = "Project"
  type        = string
}

variable "environment" {
  description = "Environment"
  type        = string
}
