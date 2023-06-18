resource "aws_api_gateway_rest_api" "api" {
  name        = var.api_name
  description = var.api_description
}

resource "aws_api_gateway_resource" "proxy_resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.proxy_resource.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_resource" "health_resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "health"
}

resource "aws_api_gateway_method" "health_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.health_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "proxy_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.proxy_resource.id
  http_method             = aws_api_gateway_method.proxy_method.http_method
  integration_http_method = "ANY"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_function_arn
}

resource "aws_api_gateway_integration" "proxy_integration_health" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.health_resource.id
  http_method             = aws_api_gateway_method.health_method.http_method
  integration_http_method = "ANY"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_function_arn

  request_templates = {
    "application/json" = jsonencode({
      "body": "$input.json('$')",
      "headers": {
        #foreach($param in $input.params().header.keySet())
        "$param": "$util.escapeJavaScript($input.params().header.get($param))"#if($foreach.hasNext),#end
        #end
      },
      "method": "$context.httpMethod",
      "query": {
        #foreach($param in $input.params().querystring.keySet())
        "$param": "$util.escapeJavaScript($input.params().querystring.get($param))"#if($foreach.hasNext),#end
        #end
      },
      "path": "$context.resourcePath",
      "requestContext": {
        "requestId": "$context.requestId",
        "accountId": "$context.identity.accountId",
        "resourceId": "$context.resourceId",
        "stage": "$context.stage",
        "identity": {
          "cognitoIdentityPoolId": "$context.identity.cognitoIdentityPoolId",
          "accountId": "$context.identity.accountId",
          "cognitoIdentityId": "$context.identity.cognitoIdentityId",
          "caller": "$context.identity.caller",
          "apiKey": "$context.identity.apiKey",
          "sourceIp": "$context.identity.sourceIp",
          "cognitoAuthenticationType": "$context.identity.cognitoAuthenticationType",
          "cognitoAuthenticationProvider": "$context.identity.cognitoAuthenticationProvider",
          "userArn": "$context.identity.userArn",
          "userAgent": "$context.identity.userAgent",
          "user": "$context.identity.user"
        }
      }
    })
  }
}

resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on  = [aws_api_gateway_integration.proxy_integration, aws_api_gateway_integration.proxy_integration_health]
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
