resource "aws_dynamodb_table" "dynamodb_table" {
  name           = var.table_name
  billing_mode   = var.billing_mode
  read_capacity  = var.read_capacity
  write_capacity = var.write_capacity

  attribute {
    name = "id"
    type = "N"
  }

  key {
    attribute_name = "id"
    type           = "HASH"
  }
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.dynamodb_table.name
}
