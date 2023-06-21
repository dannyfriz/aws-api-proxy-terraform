variable "lambda_function_name" {
  description = "Nombre de la función Lambda"
  type        = string
}

variable "lambda_runtime" {
  description = "Tiempo de ejecución de la función Lambda"
  type        = string
}

variable "lambda_handler" {
  description = "Controlador de la función Lambda"
  type        = string
}

variable "lambda_timeout" {
  description = "Tiempo de espera de la función Lambda"
  type        = number
}

variable "lambda_memory_size" {
  description = "Tamaño de memoria asignado a la función Lambda"
  type        = number
}

variable "lambda_function_code_path" {
  description = "Ruta al código de la función Lambda"
  type        = string
}

variable "api_gateway_deployment_arn" {
  description = "ARN de la API Gateway Deployment"
  type        = string
}

variable "aws_region" {
  description = "Región de la cuenta de AWS"
  type        = string
}

variable "dynamodb_table_arn" {
  description = "dynamodb_table_arn"
  type        = string
}

variable "dynamodb_table_name" {
  description = "dynamodb_table_name"
  type        = string
}


variable "proxy_lambda_function_name" {
  description = "Nombre de la función Lambda"
  type        = string
}

variable "proxy_lambda_runtime" {
  description = "Tiempo de ejecución de la función Lambda"
  type        = string
}

variable "proxy_lambda_handler" {
  description = "Controlador de la función Lambda"
  type        = string
}

variable "proxy_lambda_timeout" {
  description = "Tiempo de espera de la función Lambda"
  type        = number
}

variable "proxy_lambda_memory_size" {
  description = "Tamaño de memoria asignado a la función Lambda"
  type        = number
}

variable "proxy_function_code_path" {
  description = "Ruta al código de la función Lambda"
  type        = string
}
