resource "aws_api_gateway_rest_api" "api" {
  name        = var.api_name
  description = var.api_description
}

resource "aws_api_gateway_resource" "root_resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.root_resource.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "proxy_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.root_resource.id
  http_method             = aws_api_gateway_method.proxy_method.http_method
  integration_http_method = "ANY"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_function_arn
}

resource "aws_api_gateway_method" "health_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.root_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "health_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.root_resource.id
  http_method             = aws_api_gateway_method.health_method.http_method
  integration_http_method = "ANY"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_function_arn

  request_templates = {
    "application/json" = jsonencode({
      "statusCode": 200,
      "body": "I have reached the Lambda function.",
      "headers": {
        "Content-Type": "text/plain"
      }
    })
  }
}

resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on  = [
    aws_api_gateway_integration.proxy_integration,
    aws_api_gateway_integration.health_integration,
    aws_api_gateway_method.proxy_method,
    aws_api_gateway_method.health_method,
    aws_api_gateway_resource.root_resource
  ]
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = var.api_stage_name
}

resource "aws_api_gateway_rest_api_policy" "api_policy" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  policy      = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": "*",
        "Action": "execute-api:Invoke",
        "Resource": "arn:aws:execute-api:${var.region}:${var.account_id}:${aws_api_gateway_rest_api.api.id}/*"
      }
    ]
  })
}
