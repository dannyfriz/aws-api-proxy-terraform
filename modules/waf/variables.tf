variable "api_gateway_api_domain_name" {
  description = "Domain name of the API Gateway"
  type        = string
}

variable "api_gateway_stage_arn" {
  description = "ARN of the API Gateway stage"
  type        = string
}

variable "waf_acl_description" {
  description = "Description of the WAF ACL"
  type        = string
}

variable "waf_acl_name" {
  description = "Name of the WAF ACL"
  type        = string
}

variable "name" {
  description = "Name"
  type        = string
}

variable "project" {
  description = "Project"
  type        = string
}

variable "environment" {
  description = "Environment"
  type        = string
}

variable "api_uri" {
  description = "API URI"
  type        = string
}
