resource "aws_lambda_function" "lambda_function" {
  function_name = var.function_name
  runtime       = var.runtime
  handler       = var.handler
  timeout       = var.timeout
  memory_size   = var.memory_size

  filename      = var.function_code_path
  source_code_hash = filebase64sha256(var.function_code_path)

  role = aws_iam_role.lambda_execution_role.arn
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"
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

output "lambda_function_arn" {
  value = aws_lambda_function.lambda_function.arn
}
