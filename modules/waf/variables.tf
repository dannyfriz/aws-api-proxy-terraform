variable "waf_acl_name" {
  description = "Nombre del ACL de WAF"
  type        = string
}

variable "waf_acl_description" {
  description = "Descripción del ACL de WAF"
  type        = string
}

variable "api_gateway_execution_arn" {
  description = "ARN de la ejecución de API Gateway"
  type        = string
}

variable "waf_rule_group_arn" {
  description = "ARN del grupo de reglas de WAF"
  type        = string
}