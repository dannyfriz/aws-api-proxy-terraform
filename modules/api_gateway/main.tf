# Custom domain name for API Gateway
resource "aws_api_gateway_domain_name" "api_domain_name" {
  domain_name     = var.api_gateway_api_domain_name
  certificate_arn = var.api_gateway_acm_certificate

  tags = {
    Name        = "${var.name}-api-domain-name"
    project     = var.project
    environment = var.environment
  }
}

# Resource for API Gateway account
resource "aws_api_gateway_account" "api_gateway_account" {
  cloudwatch_role_arn = var.api_gateway_cloudwatch_role_arn
}

# Resource for the REST API of API Gateway
resource "aws_api_gateway_rest_api" "api" {
  name        = var.api_name
  description = var.api_description

  tags = {
    Name        = "${var.name}-api"
    project     = var.project
    environment = var.environment
  }
}

# Resource for the "categories" resource of API Gateway
resource "aws_api_gateway_resource" "categories_resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "categories"
}

# Resource for the "{proxy+}" resource of API Gateway
resource "aws_api_gateway_resource" "categories_proxy_resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.categories_resource.id
  path_part   = "{proxy+}"
}

# GET method for the "{proxy+}" resource of API Gateway
resource "aws_api_gateway_method" "get_categories_proxy_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.categories_proxy_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

# Lambda Proxy integration for the GET method of "{proxy+}" in API Gateway
resource "aws_api_gateway_integration" "get_categories_proxy_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.categories_proxy_resource.id
  http_method             = aws_api_gateway_method.get_categories_proxy_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.proxy_function_arn
}

# Initial deployment of API Gateway
resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id      = aws_api_gateway_rest_api.api.id
  stage_name       = var.environment
  stage_description = "Initial deployment"
}

# API Gateway Stage
resource "aws_api_gateway_stage" "api_stage" {
  deployment_id           = aws_api_gateway_deployment.api_deployment.id
  rest_api_id             = aws_api_gateway_rest_api.api.id
  stage_name              = var.environment
  cache_cluster_enabled   = var.environment == "prod" ? true : false
  cache_cluster_size      = var.environment == "prod" ? "0.5" : null

  # Additional settings to enable X-Ray tracing and access logs.
  xray_tracing_enabled = true
  access_log_settings {
    destination_arn = var.cloudwatch_log_group_arn
    format = "{\"sourceIp\":\"$context.identity.sourceIp\",\"httpMethod\":\"$context.httpMethod\",\"path\":\"$context.path\",\"status\":\"$context.status\",\"protocol\":\"$context.protocol\",\"requestId\":\"$context.requestId\",\"resourcePath\":\"$context.resourcePath\",\"integrationStatus\":\"$context.integration.integrationStatus\",\"integrationrequestId\":\"$context.integration.requestId\",\"integrationstatus\":\"$context.integration.status\",\"integrationErrorMessage\":\"$context.integrationErrorMessage\",\"integrationStatus\":\"$context.integrationStatus\",\"wafResponseCode\":\"$context.wafResponseCode\",\"webaclArn\":\"$context.webaclArn\",\"waferror\":\"$context.waf.error\",\"waflatency\":\"$context.waf.latency\",\"wafstatus\":\"$context.waf.status\",\"requestTime\":\"$context.requestTime\",\"domainName\":\"$context.domainName\",\"extendedRequestId\":\"$context.extendedRequestId\",\"userAgent\":\"$context.identity.userAgent\"}"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name        = "${var.name}-api-stage"
    project     = var.project
    environment = var.environment
  }
}

# Base path mapping to associate the custom domain name with the API stage
resource "aws_api_gateway_base_path_mapping" "api_base_path_mapping" {
  api_id      = aws_api_gateway_rest_api.api.id
  stage_name  = aws_api_gateway_stage.api_stage.stage_name
  domain_name = aws_api_gateway_domain_name.api_domain_name.domain_name
}

# Permission for API Gateway to invoke Lambda function
resource "aws_lambda_permission" "proxy_api_gateway_permission" {
  statement_id  = "AllowAPIGatewayInvocationProxy"
  action        = "lambda:InvokeFunction"
  function_name = var.proxy_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/${aws_api_gateway_stage.api_stage.stage_name}/*"
}

# Method settings for GET request in "categories" resource
resource "aws_api_gateway_method_settings" "settings_get" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = aws_api_gateway_deployment.api_deployment.stage_name
  method_path = "categories/GET"

  settings {
    logging_level       = "INFO"
    data_trace_enabled  = true
    metrics_enabled     = true
  }
}

# Method settings for POST request in "categories" resource
resource "aws_api_gateway_method_settings" "settings_post" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = aws_api_gateway_deployment.api_deployment.stage_name
  method_path = "categories/POST"

  settings {
    logging_level       = "INFO"
    data_trace_enabled  = true
    metrics_enabled     = true
  }
}
