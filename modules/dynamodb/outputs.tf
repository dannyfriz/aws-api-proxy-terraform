output "dynamodb_table_name" {
  value = aws_dynamodb_table.api_proxy_requests_table.name
}

output "dynamodb_table_arn" {
  value = aws_dynamodb_table.api_proxy_requests_table.arn
}