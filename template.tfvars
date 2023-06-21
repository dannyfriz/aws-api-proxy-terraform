# AWS region configuration
aws_account_id = "YOUR_AWS_ACCOUNT_ID"
aws_region = "us-east-1"

# API name and description
api_description = "API Proxy for API Core"
api_name = "api-proxy"

# API stage name
api_stage_name = "dev"

# Variables related to Lambda function
proxy_lambda_function_name = "proxy-function"
proxy_lambda_handler = "proxy_function.lambda_handler"
proxy_lambda_memory_size = 128
proxy_lambda_runtime = "python3.9"
proxy_lambda_timeout = 60

# Path to Lambda function code
proxy_function_code_path = "/path/to/proxy_function.zip"

# API URI
api_uri = "api.example.com"

# Variables related to API Gateway
api_gateway_acm_certificate = "arn:aws:acm:us-east-1:YOUR_CERTIFICATE_ARN"
api_gateway_api_domain_name = "api.exampledomain.com"

# Variables related to WAF
waf_acl_description = "Web ACL for API Gateway Proxy"
waf_acl_name = "APIProxyWAF"

# Other variables
dashboard_name = "api-proxy-dashboard"
environment = "dev"
name = "api-proxy-terraform"
project = "desafio-proxy"
