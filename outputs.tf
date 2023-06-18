output "api_gateway_url" {
  value = module.api_gateway.api_gateway_url
}

output "lambda_function_arn" {
  value = module.lambda_function.lambda_function_arn
}

output "dynamodb_table_name" {
  value = module.dynamodb.dynamodb_table_name
}

output "backend_s3_bucket" {
  value = "nombre-del-bucket-s3"
}

output "backend_s3_key" {
  value = "ruta-dentro-del-bucket/terraform.tfstate"
}

output "backend_dynamodb_table" {
  value = "nombre-de-la-tabla-dynamodb"
}
