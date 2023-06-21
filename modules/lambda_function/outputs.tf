




output "iam_execution_role_name" {
  value = aws_iam_role.lambda_execution_role.name
}

output "proxy_function_arn" {
  value = aws_lambda_function.proxy_lambda_function.invoke_arn
}

output "proxy_function_name" {
  value = aws_lambda_function.proxy_lambda_function.function_name
}