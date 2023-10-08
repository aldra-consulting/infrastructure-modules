variable "common" {
  description = "Common variables"
  type        = object({ project = map(string), tags = map(string) })
}

variable "account" {
  description = "Account variables"
  type        = object({ tags = map(string) })
}

variable "region" {
  description = "Region variables"
  type        = object({ name = string, tags = map(string) })
}

variable "environment" {
  description = "Environment variables"
  type        = object({ name = string, project = map(string), tags = map(string) })
}

variable "namespace" {
  description = "Unique namespace"
  type        = string
}

variable "tags" {
  description = "Tags"
  type        = map(string)
}

variable "vpc" {
  description = "VPC attributes"
  type        = object({ id = string, private_subnets = list(string), private_subnets_cidr_blocks = list(string) })
}

variable "services" {
  description = "List of ECS service definitions"
  type        = list(object({ name = string, environment = map(string) }))
}
