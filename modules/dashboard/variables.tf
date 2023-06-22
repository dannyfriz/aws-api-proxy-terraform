variable "dashboard_name" {
  description = "The name of the dashboard"
  type        = string
}

variable "api_id" {
  description = "The ID of the API for which to create the dashboard"
  type        = string
}

variable "lambda_function_name" {
  description = "The name of the Lambda function"
  type        = string
}

variable "email_control_center" {
  description = "email for sns topic"
  type        = string
}