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

variable "region" {
  description = "Region de la Cuenta de AWS"
  type        = string
}

variable "account_id" {
  description = "Id de la Cuenta de AWS"
  type        = string
}