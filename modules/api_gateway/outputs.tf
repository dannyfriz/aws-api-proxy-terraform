output "api_gateway_url" {
  value = aws_api_gateway_deployment.api_deployment.invoke_url
}

output "api_gateway_deployment_arn" {
  value = "arn:aws:execute-api:${var.aws_region}:${var.aws_account_id}:${aws_api_gateway_rest_api.api.id}/${aws_api_gateway_deployment.api_deployment.stage_name}"
}

output "api_gateway_execution_arn" {
  description = "ARN de ejecución de la etapa de la API Gateway"
  value       = aws_api_gateway_stage.stage.execution_arn
}