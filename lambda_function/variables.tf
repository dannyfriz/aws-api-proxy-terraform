variable "function_name" {
  description = "Nombre de la función Lambda"
  type        = string
}

variable "runtime" {
  description = "Entorno de ejecución de la función Lambda"
  type        = string
  default     = "python3.9"
}

variable "handler" {
  description = "Controlador (handler) de la función Lambda"
  type        = string
  default     = "lambda_function.lambda_handler"
}

variable "timeout" {
  description = "Tiempo de espera (timeout) de la función Lambda"
  type        = number
  default     = 10
}

variable "memory_size" {
  description = "Tamaño de memoria de la función Lambda"
  type        = number
  default     = 128
}

variable "function_code_path" {
  description = "Ruta del archivo de código de la función Lambda"
  type        = string
}
