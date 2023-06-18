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

variable "region" {
  description = "Region de la Cuenta de AWS"
  type        = string
}

variable "api_gateway_arn" {
  description = "ARN de la api gateway"
  type        = string
}

