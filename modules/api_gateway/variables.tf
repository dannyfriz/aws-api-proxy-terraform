variable "api_name" {
  description = "Nombre de la API Gateway"
  type        = string
}

variable "api_description" {
  description = "Descripción de la API Gateway"
  type        = string
}

variable "api_stage_name" {
  description = "Nombre de la etapa de la API Gateway"
  type        = string
}

variable "aws_region" {
  description = "Región de AWS"
  type        = string
}

variable "aws_account_id" {
  description = "ID de la cuenta de AWS"
  type        = string
}

variable "cloudwatch_log_group_arn" {
  description = "cloudwatch_log_group_arn"
  type        = string
}

variable "api_uri" {
  description = "URI del dominio de la API Gateway"
  type        = string
}

variable "api_gateway_cloudwatch_role_arn" {
  description = "api_gateway_cloudwatch_role_arn"
  type        = string
}

variable "api_gateway_api_domain_name" {
  description = "api_gateway_api_domain_name"
  type        = string
}

variable "api_gateway_acm_certificate" {
  description = "api_gateway_acm_certificate"
  type        = string
}

variable "proxy_function_arn" {
  description = "proxy_function_arn"
  type        = string
}

variable "proxy_function_name" {
  description = "proxy_function_name"
  type        = string
}

variable "name" {
  description = "name"
  type        = string
}

variable "project" {
  description = "project"
  type        = string
}

variable "environment" {
  description = "environment"
  type        = string
}