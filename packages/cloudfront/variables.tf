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

variable "cloudfront_distributions" {
  description = "List of Cloudfront distribution definitions"
  type = list(object({
    domain_name = string
    name        = string
    cache_behaviours = list(object({
      path = optional(string)
      type = string
      origin = object({
        id          = string
        domain_name = string
      })
    }))
  }))
}
