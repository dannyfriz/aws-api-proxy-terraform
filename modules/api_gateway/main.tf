resource "aws_api_gateway_rest_api" "api" {
  name        = var.api_name
  description = var.api_description
}

resource "aws_api_gateway_resource" "categories_resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "categories"
}

resource "aws_api_gateway_resource" "categories_proxy_resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.categories_resource.id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "get_categories_proxy_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.categories_proxy_resource.id
  http_method   = "GET"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "get_categories_proxy_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.categories_proxy_resource.id
  http_method             = aws_api_gateway_method.get_categories_proxy_method.http_method
  integration_http_method = "GET"
  type                    = "HTTP_PROXY"
  uri                     = "https://api.mercadolibre.com/categories/{proxy}"

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }

  passthrough_behavior = "WHEN_NO_MATCH"
}

resource "aws_api_gateway_method_response" "ok_response" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.categories_proxy_resource.id
  http_method = aws_api_gateway_method.get_categories_proxy_method.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "ok_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.categories_proxy_resource.id
  http_method = aws_api_gateway_method.get_categories_proxy_method.http_method
  status_code  = aws_api_gateway_method_response.ok_response.status_code

  response_templates = {
    "application/json" = ""
  }
}

resource "aws_api_gateway_method_response" "bad_request_response" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.categories_proxy_resource.id
  http_method = aws_api_gateway_method.get_categories_proxy_method.http_method
  status_code = "400"
}

resource "aws_api_gateway_integration_response" "bad_request_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.categories_proxy_resource.id
  http_method = aws_api_gateway_method.get_categories_proxy_method.http_method
  status_code  = aws_api_gateway_method_response.bad_request_response.status_code

  selection_pattern = "4\\d{2}"

  response_templates = {
    "application/json" = ""
  }
}

resource "aws_api_gateway_method" "categories_options" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.categories_proxy_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "categories_options_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.categories_proxy_resource.id
  http_method = aws_api_gateway_method.categories_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true,
  }
}

resource "aws_api_gateway_integration" "categories_options" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.categories_proxy_resource.id
  http_method = aws_api_gateway_method.categories_options.http_method
  type        = "MOCK"
}

resource "aws_api_gateway_integration_response" "categories_options_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.categories_proxy_resource.id
  http_method = aws_api_gateway_method.categories_options.http_method
  status_code = aws_api_gateway_method_response.categories_options_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'",
  }
}

resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on = [
    aws_api_gateway_integration.get_categories_proxy_integration,
    aws_api_gateway_method.get_categories_proxy_method,
    aws_api_gateway_resource.categories_proxy_resource,
    aws_api_gateway_method_response.ok_response,
    aws_api_gateway_integration_response.ok_integration_response,
    aws_api_gateway_method.categories_options,
    aws_api_gateway_method_response.categories_options_200,
    aws_api_gateway_integration.categories_options,
    aws_api_gateway_integration_response.categories_options_200
  ]

  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = var.api_stage_name
}

resource "aws_api_gateway_stage" "stage" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  deployment_id = aws_api_gateway_deployment.api_deployment.id
  stage_name    = "${var.api_stage_name}"

  xray_tracing_enabled = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.access_logs.arn
    format          = "$context.identity.sourceIp $context.identity.caller $context.identity.user [$context.requestTime] \"$context.httpMethod $context.routeKey $context.protocol\" $context.status $context.responseLength $context.requestId"
  }
}

resource "aws_cloudwatch_log_group" "access_logs" {
  name = "/aws/apigateway/${var.api_name}-access-logs"
}
