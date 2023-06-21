# Output to retrieve the API Gateway URL
output "api_gateway_url" {
  value       = module.api_gateway.api_gateway_url
  description = "URL of the API Gateway"
}
