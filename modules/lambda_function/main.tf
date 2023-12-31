# Policy for lambda_log_policy permission on the log group
resource "aws_iam_policy" "lambda_log_policy" {
  name        = "lambda_log_policy"
  description = "Allows Lambda function to write logs to CloudWatch"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    }
  ]
}
EOF
  tags = {
    Name        = "${var.name}-lambda-log-policy"
    project     = var.project
    environment = var.environment
  }
}

# Lambda execution role lambda_execution_role
resource "aws_iam_role" "lambda_execution_role" {
  name               = "lambda_execution_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
  tags = {
    Name        = "${var.name}-lambda-execution-role"
    project     = var.project
    environment = var.environment
  }
}

# Attach lambda_log_policy to lambda_execution_role
resource "aws_iam_role_policy_attachment" "lambda_log_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_log_policy.arn
  role       = aws_iam_role.lambda_execution_role.name
}

# Data resource to get the current region
data "aws_region" "current" {}

# Lambda function resource proxy_lambda_function
resource "aws_lambda_function" "proxy_lambda_function" {
  function_name    = var.proxy_lambda_function_name
  runtime          = var.proxy_lambda_runtime
  handler          = var.proxy_lambda_handler
  timeout          = var.proxy_lambda_timeout
  memory_size      = var.proxy_lambda_memory_size

  filename         = var.proxy_function_code_path
  source_code_hash = filebase64sha256(var.proxy_function_code_path)

  role = aws_iam_role.lambda_execution_role.arn

  # CloudWatch log configuration
  tracing_config {
    mode = "Active"
  }

  environment {
    variables = {
      LOG_LEVEL               = "INFO"
      API_DOMAIN              = var.api_uri
      IP_ADDRESS              = "$context.identity.sourceIp"
      HOST                    = "$context.domainName"
    }
  }

  tags = {
    Name        = "${var.name}-proxy-lambda-function"
    project     = var.project
    environment = var.environment
  }
}

# CloudWatch log group resource proxy_lambda_log_group
resource "aws_cloudwatch_log_group" "proxy_lambda_log_group" {
  name              = "/aws/lambda/${var.proxy_lambda_function_name}"
  retention_in_days = 30

  tags = {
    Name        = "${var.name}-proxy-lambda-log-group"
    project     = var.project
    environment = var.environment
  }
}

# Permission for the log group proxy_lambda_log_group
resource "aws_lambda_permission" "proxy_lambda_log_group_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.proxy_lambda_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = aws_cloudwatch_log_group.proxy_lambda_log_group.arn
}

# Permission for API Gateway to invoke proxy_lambda_function
resource "aws_lambda_permission" "proxy_api_gateway_permission" {
  statement_id  = "AllowAPIGatewayInvocation"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.proxy_lambda_function.function_name
  principal     = "apigateway.amazonaws.com"
}
