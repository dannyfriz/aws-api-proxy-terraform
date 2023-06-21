# Recurso de función lambda dynamodb_function
resource "aws_lambda_function" "dynamodb_function" {
  function_name    = var.lambda_function_name
  runtime          = var.lambda_runtime
  handler          = var.lambda_handler
  timeout          = var.lambda_timeout
  memory_size      = var.lambda_memory_size

  filename         = var.dynamodb_function_code_path
  source_code_hash = filebase64sha256(var.dynamodb_function_code_path)

  role = aws_iam_role.lambda_execution_role.arn

  # Configuración de registro de CloudWatch
  tracing_config {
    mode = "Active"
  }

  environment {
    variables = {
      LOG_LEVEL            = "INFO"
      DYNAMODB_TABLE_NAME  = var.dynamodb_table_name
    }
  }
}

# Recurso de grupo de registro de CloudWatch lambda_log_group
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 30
}

# Política de permisos lambda_log_policy para el grupo de registro
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

# Rol de ejecución de Lambda lambda_execution_role
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

# Asociar la política lambda_log_policy al rol de ejecución de Lambda
resource "aws_iam_role_policy_attachment" "lambda_log_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_log_policy.arn
  role       = aws_iam_role.lambda_execution_role.name
}

# Asociar el grupo de registro lambda_log_group a la función Lambda
resource "aws_lambda_permission" "lambda_log_group_permission" {
  statement_id  = "AllowExecution"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.dynamodb_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = aws_cloudwatch_log_group.lambda_log_group.arn
}

# Recurso de datos para obtener la región actual
data "aws_region" "current" {}

# Asociar permisos para invocar la función Lambda desde la API Gateway
resource "aws_lambda_permission" "api_gateway_permission" {
  statement_id  = "AllowAPIGatewayInvocation"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.dynamodb_function.function_name
  principal     = "apigateway.amazonaws.com"
}

# Política de permisos lambda_dynamodb_write_policy para escribir en DynamoDB
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
        "dynamodb:DeleteItem",
        "dynamodb:BatchWriteItem"
      ],
      "Resource": "${var.dynamodb_table_arn}"
    }
  ]
}
EOF
}

# Asociar la política lambda_dynamodb_write_policy al rol de ejecución de Lambda
resource "aws_iam_role_policy_attachment" "lambda_dynamodb_write_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_dynamodb_write_policy.arn
  role       = aws_iam_role.lambda_execution_role.name
}

# Recurso de función lambda proxy_lambda_function
resource "aws_lambda_function" "proxy_lambda_function" {
  function_name    = var.proxy_lambda_function_name
  runtime          = var.proxy_lambda_runtime
  handler          = var.proxy_lambda_handler
  timeout          = var.proxy_lambda_timeout
  memory_size      = var.proxy_lambda_memory_size

  filename         = var.proxy_function_code_path
  source_code_hash = filebase64sha256(var.proxy_function_code_path)

  role = aws_iam_role.lambda_execution_role.arn

  # Configuración de registro de CloudWatch
  tracing_config {
    mode = "Active"
  }

  environment {
  variables = {
    LOG_LEVEL               = "INFO"
    API_DOMAIN              = var.api_uri
    DYNAMODB_FUNCTION_NAME  = aws_lambda_function.dynamodb_function.function_name
    IP_ADDRESS              = "$context.identity.sourceIp"
    HOST                    = "$context.domainName"
  }
}

}

# Recurso de grupo de registro de CloudWatch proxy_lambda_log_group
resource "aws_cloudwatch_log_group" "proxy_lambda_log_group" {
  name              = "/aws/lambda/${var.proxy_lambda_function_name}"
  retention_in_days = 30
}

# Permiso para el grupo de registro proxy_lambda_log_group
resource "aws_lambda_permission" "proxy_lambda_log_group_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.proxy_lambda_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = aws_cloudwatch_log_group.proxy_lambda_log_group.arn
}

# Permiso para la API Gateway para invocar proxy_lambda_function
resource "aws_lambda_permission" "proxy_api_gateway_permission" {
  statement_id  = "AllowAPIGatewayInvocation"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.proxy_lambda_function.function_name
  principal     = "apigateway.amazonaws.com"
}

# Permiso para que dynamodb_function invoque a proxy_lambda_function
resource "aws_lambda_permission" "dynamodb_proxy_lambda_permission" {
  statement_id  = "AllowLambdaInvocation"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.dynamodb_function.function_name
  principal     = "lambda.amazonaws.com"
  source_arn    = aws_lambda_function.proxy_lambda_function.arn
}




# Política de permisos para que proxy_lambda_function invoque a dynamodb_function
data "aws_iam_policy_document" "proxy_lambda_invoke_policy" {
  statement {
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction"
    ]
    resources = [
      aws_lambda_function.dynamodb_function.arn
    ]
  }
}

# Crear la política de permisos
resource "aws_iam_policy" "proxy_lambda_invoke_policy" {
  name        = "proxy_lambda_invoke_policy"
  description = "Allows proxy_lambda_function to invoke dynamodb_function"
  policy      = data.aws_iam_policy_document.proxy_lambda_invoke_policy.json
}

# Asociar la política proxy_lambda_invoke_policy al rol de ejecución de Lambda
resource "aws_iam_role_policy_attachment" "proxy_lambda_invoke_policy_attachment" {
  policy_arn = aws_iam_policy.proxy_lambda_invoke_policy.arn
  role       = aws_iam_role.lambda_execution_role.name
}


