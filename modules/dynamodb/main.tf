resource "aws_dynamodb_table" "dynamodb_table" {
  name           = var.dynamodb_table_name
  billing_mode   = var.dynamodb_billing_mode
  read_capacity  = var.dynamodb_read_capacity
  write_capacity = var.dynamodb_write_capacity

  attribute {
    name = "id"
    type = "N"
  }

  hash_key = "id"
}
