variable "waf_acl_name" {
  description = "Nombre del ACL de WAF"
  type        = string
}

variable "waf_acl_description" {
  description = "Descripción del ACL de WAF"
  type        = string
}

variable "api_gateway_stage_arn" {
  description = "ARN del escenario de API Gateway"
  type        = string
}

variable "waf_rule_group_arn" {
  description = "ARN del grupo de reglas de WAF"
  type        = string
}

variable "api_gateway_api_domain_name" {
  description = "api_gateway_api_domain_name"
  type        = string
}
