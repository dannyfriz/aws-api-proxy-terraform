resource "aws_lambda_function" "lambda_function" {
  function_name    = var.lambda_function_name
  runtime          = var.lambda_runtime
  handler          = var.lambda_handler
  timeout          = var.lambda_timeout
  memory_size      = var.lambda_memory_size

  filename         = var.lambda_function_code_path
  source_code_hash = filebase64sha256(var.lambda_function_code_path)

  role             = aws_iam_role.lambda_execution_role.arn
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
