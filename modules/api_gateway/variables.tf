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

variable "lambda_function_arn" {
  description = "ARN de la función Lambda"
  type        = string
}

variable "lambda_function_name" {
  description = "Name de la función Lambda"
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