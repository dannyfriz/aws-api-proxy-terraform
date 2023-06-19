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

variable "aws_region" {
  description = "Region de la Cuenta de AWS"
  type        = string
}

variable "aws_account_id" {
  description = "Id de la Cuenta de AWS"
  type        = string
}

variable "lambda_function_name" {
  description = "Name de la función Lambda"
  type        = string
}

variable "notification_email" {
  description = "Notification_email"
  type        = string
}
