output "api_gateway_url" {
  value = aws_api_gateway_deployment.api_deployment.invoke_url
}

output "api_gateway_arn" {
  value = aws_api_gateway_rest_api.api.arn
}