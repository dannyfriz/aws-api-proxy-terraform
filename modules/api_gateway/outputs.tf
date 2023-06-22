output "api_gateway_url" {
  description = "URL of the API Gateway"
  value       = aws_api_gateway_deployment.api_deployment.invoke_url
}

output "api_gateway_deployment_arn" {
  description = "ARN of the API Gateway deployment"
  value       = "arn:aws:execute-api:${var.aws_region}:${var.aws_account_id}:${aws_api_gateway_rest_api.api.id}/${aws_api_gateway_deployment.api_deployment.stage_name}"
}

output "api_gateway_stage_arn" {
  description = "ARN of the API Gateway stage"
  value       = aws_api_gateway_stage.api_stage.arn
}

output "api_id" {
  description = "ID of the API Gateway"
  value       = aws_api_gateway_rest_api.api.name
}
