output "iam_execution_role_name" {
  value = aws_iam_role.lambda_execution_role.name
  description = "Name of the IAM execution role"
}

output "proxy_function_arn" {
  value = aws_lambda_function.proxy_lambda_function.invoke_arn
  description = "ARN of the proxy Lambda function"
}

output "proxy_function_name" {
  value = aws_lambda_function.proxy_lambda_function.function_name
  description = "Name of the proxy Lambda function"
}
