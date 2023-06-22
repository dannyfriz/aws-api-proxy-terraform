output "api_gateway_cloudwatch_role_arn" {
  description = "ARN of the IAM role used by API Gateway to write logs to CloudWatch"
  value       = aws_iam_role.api_gateway_cloudwatch_role.arn
}
