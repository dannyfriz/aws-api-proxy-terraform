resource "aws_lambda_function" "lambda_function" {
  function_name    = var.lambda_function_name
  runtime          = var.lambda_runtime
  handler          = var.lambda_handler
  timeout          = var.lambda_timeout
  memory_size      = var.lambda_memory_size

  filename         = var.lambda_function_code_path
  source_code_hash = filebase64sha256(var.lambda_function_code_path)

  role = aws_iam_role.lambda_execution_role.arn

  # Agregar configuración de registro de CloudWatch
  tracing_config {
    mode = "Active"
  }

  environment {
    variables = {
      LOG_LEVEL = "INFO"
      DYNAMODB_TABLE_NAME = var.dynamodb_table_name
    }
  }
}

# Crear un nuevo recurso de grupo de registro de CloudWatch
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 30
}

# Crear una política de permisos para el grupo de registro
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

# Crear el rol de ejecución de Lambda
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

# Asociar la política de permisos al rol de ejecución de Lambda
resource "aws_iam_role_policy_attachment" "lambda_log_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_log_policy.arn
  role       = aws_iam_role.lambda_execution_role.name
}

# Asociar el grupo de registro a la función Lambda
resource "aws_lambda_permission" "lambda_log_group_permission" {
  statement_id  = "AllowExecution"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = aws_cloudwatch_log_group.lambda_log_group.arn
}

# Recurso de datos para obtener la región actual
data "aws_region" "current" {}

# Asociar permisos para invocar la función Lambda desde la API Gateway
resource "aws_lambda_permission" "api_gateway_permission" {
  statement_id  = "AllowAPIGatewayInvocation"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal     = "apigateway.amazonaws.com"
}

resource "aws_iam_policy" "lambda_dynamodb_write_policy" {
  name        = "lambda_dynamodb_write_policy"
  description = "Allows Lambda function to write to DynamoDB"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:PutItem",
        "dynamodb:UpdateItem",
        "dynamodb:DeleteItem"
      ],
      "Resource": "${var.dynamodb_table_arn}"
    }
  ]
}
EOF
}

# Asociar la política de permisos al rol de ejecución de Lambda
resource "aws_iam_role_policy_attachment" "lambda_dynamodb_write_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_dynamodb_write_policy.arn
  role       = aws_iam_role.lambda_execution_role.name
}