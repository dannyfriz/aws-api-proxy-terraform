output "dashboard_arn" {
  description = "The ARN of the created dashboard"
  value       = aws_cloudwatch_dashboard.api_dashboard.dashboard_arn
}