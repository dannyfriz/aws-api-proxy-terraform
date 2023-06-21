variable "api_gateway_deployment_arn" {
  description = "ARN of the API Gateway Deployment"
  type        = string
}

variable "api_uri" {
  description = "API URI"
  type        = string
}

variable "aws_region" {
  description = "AWS account region"
  type        = string
}

variable "environment" {
  description = "Environment"
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

variable "proxy_function_code_path" {
  description = "Path to the Lambda function code"
  type        = string
}

variable "proxy_lambda_function_name" {
  description = "Lambda function name"
  type        = string
}

variable "proxy_lambda_handler" {
  description = "Lambda function handler"
  type        = string
}

variable "proxy_lambda_memory_size" {
  description = "Memory size allocated to the Lambda function"
  type        = number
}

variable "proxy_lambda_runtime" {
  description = "Lambda function runtime"
  type        = string
}

variable "proxy_lambda_timeout" {
  description = "Lambda function timeout"
  type        = number
}
