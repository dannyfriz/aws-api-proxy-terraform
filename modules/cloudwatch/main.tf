# Grupo de logs en CloudWatch para la API Gateway
resource "aws_cloudwatch_log_group" "access_logs" {
  name = "/aws/apigateway/${var.api_name}-access-logs"

  retention_in_days = 7
}

# Política de recursos de logs en CloudWatch para la API Gateway
resource "aws_cloudwatch_log_resource_policy" "log_resource_policy" {
  policy_name = "APIGatewayLogResourcePolicy"

  policy_document = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowPutLogEvents",
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": "logs:PutLogEvents",
      "Resource": "arn:aws:logs:${var.aws_region}:${var.aws_account_id}:log-group:${aws_cloudwatch_log_group.access_logs.name}:*"
    },
    {
      "Sid": "AllowCreateLogStream",
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": "logs:CreateLogStream",
      "Resource": "arn:aws:logs:${var.aws_region}:${var.aws_account_id}:log-group:${aws_cloudwatch_log_group.access_logs.name}:log-stream:*"
    },
    {
      "Sid": "AllowGetLogEvents",
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": "logs:GetLogEvents",
      "Resource": "arn:aws:logs:${var.aws_region}:${var.aws_account_id}:log-group:${aws_cloudwatch_log_group.access_logs.name}:log-stream:*"
    }
  ]
}
EOF
}
