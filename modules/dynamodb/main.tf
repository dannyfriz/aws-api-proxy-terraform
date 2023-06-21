resource "aws_dynamodb_table" "api_proxy_requests_table" {
  name           = var.dynamodb_table_name
  billing_mode   = var.dynamodb_billing_mode
  hash_key       = "RequestId"

  attribute {
    name = "RequestId"
    type = "S"
  }

  attribute {
    name = "Timestamp"
    type = "S"
  }

  attribute {
    name = "IPAddress"
    type = "S"
  }

  attribute {
    name = "Host"
    type = "S"
  }

  attribute {
    name = "RequestData"
    type = "S"
  }

  global_secondary_index {
    name               = "TimestampIndex"
    hash_key           = "Timestamp"
    projection_type    = "ALL"
    write_capacity     = var.dynamodb_write_capacity
    read_capacity      = var.dynamodb_read_capacity
  }
}
