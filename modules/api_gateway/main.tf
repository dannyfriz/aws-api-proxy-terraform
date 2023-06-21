# Nombre de dominio personalizado para la API Gateway
resource "aws_api_gateway_domain_name" "api_domain_name" {
  domain_name = var.api_gateway_api_domain_name
  certificate_arn = var.api_gateway_acm_certificate
}

# Mapeo de ruta base para asociar el nombre de dominio personalizado con la etapa de la API
resource "aws_api_gateway_base_path_mapping" "api_base_path_mapping" {
  api_id      = aws_api_gateway_rest_api.api.id
  stage_name  = aws_api_gateway_stage.stage.stage_name
  domain_name = aws_api_gateway_domain_name.api_domain_name.domain_name
}

# Recurso para la cuenta de API Gateway
resource "aws_api_gateway_account" "api_gateway_account" {
  cloudwatch_role_arn = var.api_gateway_cloudwatch_role_arn
}

# Recurso para la API REST de API Gateway
resource "aws_api_gateway_rest_api" "api" {
  name        = var.api_name
  description = var.api_description
}

# Recurso para el recurso "categories" de la API Gateway
resource "aws_api_gateway_resource" "categories_resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "categories"
}

# Recurso para el recurso "categories_proxy" de la API Gateway
resource "aws_api_gateway_resource" "categories_proxy_resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.categories_resource.id
  path_part   = "{proxy+}"
}

# Método GET para el recurso "categories_proxy" de la API Gateway
resource "aws_api_gateway_method" "get_categories_proxy_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.categories_proxy_resource.id
  http_method   = "GET"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.proxy" = true
  }
}

# Integración HTTP_PROXY para el método GET de "categories_proxy" de la API Gateway
resource "aws_api_gateway_integration" "get_categories_proxy_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.categories_proxy_resource.id
  http_method             = aws_api_gateway_method.get_categories_proxy_method.http_method
  integration_http_method = "GET"
  type                    = "HTTP_PROXY"
  uri                     = "https://${var.api_uri}/categories/{proxy}"

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }

  passthrough_behavior = "WHEN_NO_MATCH"
}

# Respuesta de integración exitosa para el método GET de "categories_proxy" de la API Gateway
resource "aws_api_gateway_integration_response" "ok_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.categories_proxy_resource.id
  http_method = aws_api_gateway_method.get_categories_proxy_method.http_method
  status_code  = aws_api_gateway_method_response.ok_response.status_code

  response_templates = {
    "application/json" = ""
  }
}

# Respuesta exitosa para el método GET de "categories_proxy" de la API Gateway
resource "aws_api_gateway_method_response" "ok_response" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.categories_proxy_resource.id
  http_method = aws_api_gateway_method.get_categories_proxy_method.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

# Respuesta de error para el método GET de "categories_proxy" de la API Gateway
resource "aws_api_gateway_method_response" "bad_request_response" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.categories_proxy_resource.id
  http_method = aws_api_gateway_method.get_categories_proxy_method.http_method
  status_code = "400"

  response_models = {
    "application/json" = "Empty"
  }
}

# Método OPTIONS para el recurso "categories_proxy" de la API Gateway
resource "aws_api_gateway_method" "categories_options" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.categories_proxy_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# Respuesta exitosa para el método OPTIONS de "categories_proxy" de la API Gateway
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

# Integración MOCK para el método OPTIONS de "categories_proxy" de la API Gateway
resource "aws_api_gateway_integration" "categories_options" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.categories_proxy_resource.id
  http_method = aws_api_gateway_method.categories_options.http_method
  type        = "MOCK"
}

# Respuesta exitosa para la integración MOCK del método OPTIONS de "categories_proxy" de la API Gateway
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

# Despliegue de la API Gateway
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

# Etapa de la API Gateway
resource "aws_api_gateway_stage" "stage" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  deployment_id = aws_api_gateway_deployment.api_deployment.id
  stage_name    = var.api_stage_name

  cache_cluster_enabled = false # Habilitar en Productivo
  cache_cluster_size    = "0.5"   # Tamaño del caché en GB, puede ser 0.5, 6.1, 13.5, 28.4, 58.2, 118, 237

  xray_tracing_enabled = true

  lifecycle {
    create_before_destroy = true
  }

  access_log_settings {
    destination_arn = var.cloudwatch_log_group_arn
    format = "{\"stage\":\"$context.stage\",\"request_id\":\"$context.requestId\",\"api_id\":\"$context.apiId\",\"resource_path\":\"$context.resourcePath\",\"resource_id\":\"$context.resourceId\",\"http_method\":\"$context.httpMethod\",\"source_ip\":\"$context.identity.sourceIp\",\"user-agent\":\"$context.identity.userAgent\",\"account_id\":\"$context.identity.accountId\",\"api_key\":\"$context.identity.apiKey\",\"caller\":\"$context.identity.caller\",\"user\":\"$context.identity.user\",\"user_arn\":\"$context.identity.userArn\"}"
  }
}

resource "aws_api_gateway_method_settings" "settings" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = aws_api_gateway_stage.stage.stage_name
  method_path = "*/*"  # Ajusta esto según tus necesidades.

  settings {
    caching_enabled    = false    # Habilitar en Productivo
    cache_ttl_in_seconds = 3600  # TTL del caché en segundos. Equivale a 1 hora.
    cache_data_encrypted   = false # Habilitar en Productivo
    data_trace_enabled = true
    logging_level      = "INFO"
    metrics_enabled    = true
    throttling_burst_limit = 5000 # Mayor Capacidad solicitar ticket AWS Qoute
    throttling_rate_limit  = 10000 # Mayor Capacidad solicitar ticket AWS Qoute
  }
}

# Respuesta 403
resource "aws_api_gateway_gateway_response" "waf_403_response" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  status_code = "403"
  response_type = "ACCESS_DENIED"
  
  response_templates = {
    "application/json" = jsonencode({
      message = "Access Denied: Request blocked by AWS WAF"
    })
  }
}
