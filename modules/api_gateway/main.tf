# Nombre de dominio personalizado para la API Gateway
resource "aws_api_gateway_domain_name" "api_domain_name" {
  domain_name = var.api_gateway_api_domain_name
  certificate_arn = var.api_gateway_acm_certificate
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

# Recurso para el recurso "{proxy+}" de la API Gateway
resource "aws_api_gateway_resource" "categories_proxy_resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.categories_resource.id
  path_part   = "{proxy+}"
}

# Método GET para el recurso "{proxy+}" de la API Gateway
resource "aws_api_gateway_method" "get_categories_proxy_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.categories_proxy_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

# Integración Lambda Proxy para el método GET de "{proxy+}" de la API Gateway
resource "aws_api_gateway_integration" "get_categories_proxy_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.categories_proxy_resource.id
  http_method             = aws_api_gateway_method.get_categories_proxy_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.proxy_function_arn
}

# Despliegue inicial de la API Gateway
resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on  = [aws_api_gateway_integration.get_categories_proxy_integration]
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "v1"
  stage_description = "Initial deployment"
}

# Etapa de la API Gateway
resource "aws_api_gateway_stage" "api_stage" {
  deployment_id = aws_api_gateway_deployment.api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = "v2"
}

# Mapeo de ruta base para asociar el nombre de dominio personalizado con la etapa de la API
resource "aws_api_gateway_base_path_mapping" "api_base_path_mapping" {
  api_id      = aws_api_gateway_rest_api.api.id
  stage_name  = aws_api_gateway_stage.api_stage.stage_name
  domain_name = aws_api_gateway_domain_name.api_domain_name.domain_name
}

# Permiso para que API Gateway invoque la función Lambda
resource "aws_lambda_permission" "proxy_api_gateway_permission" {
  statement_id  = "AllowAPIGatewayInvocationProxy"
  action        = "lambda:InvokeFunction"
  function_name = var.proxy_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/${aws_api_gateway_stage.api_stage.stage_name}/*"
}
