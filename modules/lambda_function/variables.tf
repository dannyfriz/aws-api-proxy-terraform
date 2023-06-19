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

variable "region" {
  description = "Región de la cuenta de AWS"
  type        = string
}
