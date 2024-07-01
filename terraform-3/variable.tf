# variables.tf
variable "region" {
  default = "ap-northeast-1"
}

variable "availability_zones" {
  description = "List of availability zones to be used for the subnets"
  type        = list(string)
  default     = ["ap-northeast-1a", "ap-northeast-1c"]
}

