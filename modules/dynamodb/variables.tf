variable "table_name" {
  description = "Nombre de la tabla DynamoDB"
  type        = string
}

variable "billing_mode" {
  description = "Modo de facturación de DynamoDB"
  type        = string
  default     = "PROVISIONED"
}

variable "read_capacity" {
  description = "Capacidad de lectura de DynamoDB"
  type        = number
  default     = 5
}

variable "write_capacity" {
  description = "Capacidad de escritura de DynamoDB"
  type        = number
  default     = 5
}
