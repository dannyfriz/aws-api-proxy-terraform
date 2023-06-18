variable "dynamodb_billing_mode" {
  description = "Modo de facturación de la tabla DynamoDB"
  type        = string
}

variable "dynamodb_read_capacity" {
  description = "Capacidad de lectura de la tabla DynamoDB"
  type        = number
}

variable "dynamodb_write_capacity" {
  description = "Capacidad de escritura de la tabla DynamoDB"
  type        = number
}

variable "dynamodb_table_name" {
  description = "Nombre de la tabla DynamoDB"
  type        = string
}