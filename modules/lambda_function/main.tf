resource "aws_lambda_function" "lambda_function" {
  function_name    = var.lambda_function_name
  runtime          = var.lambda_runtime
  handler          = var.lambda_handler
  timeout          = var.lambda_timeout
  memory_size      = var.lambda_memory_size

  filename         = var.lambda_function_code_path
  source_code_hash = filebase64sha256(var.lambda_function_code_path)

  role = aws_iam_role.lambda_execution_role.arn

  tracing_config {
    mode = "Active"
  }

  environment {
    variables = {
      LOG_LEVEL = "INFO"
    }
  }
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 30
}

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
}

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
}

resource "aws_iam_role_policy_attachment" "lambda_log_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_log_policy.arn
  role       = aws_iam_role.lambda_execution_role.name
}

resource "aws_lambda_permission" "lambda_log_group_permission" {
  statement_id  = "AllowExecution"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal     = "logs.${data.aws_region.current.name}.amazonaws.com"
  source_arn    = aws_cloudwatch_log_group.lambda_log_group.arn
}

resource "aws_lambda_permission" "api_gateway_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.api_gateway_deployment_arn}/*/GET/"
}

resource "aws_lambda_permission" "health_check_permission" {
  statement_id  = "AllowHealthCheckInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.api_gateway_deployment_arn}/*/GET/"
}

data "aws_region" "current" {}