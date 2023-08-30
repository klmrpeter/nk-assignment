data "aws_region" "current" {
}

variable "vpc_ip_range" {
  default     = "10.20.0.0/16"
  type        = string
  description = "CIDR block range for the VPC's IP addresses."
}

variable "subnet_ip_range-1" {
  default     = "10.20.0.0/20"
  type        = string
  description = "CIDR block range for subnet 1(public) within the VPC."
}

variable "subnet_ip_range-2" {
  default     = "10.20.16.0/20"
  type        = string
  description = "CIDR block range for subnet 2(public) within the VPC."
}

variable "subnet_ip_range-3" {
  default     = "10.20.32.0/20"
  type        = string
  description = "CIDR block range for subnet 3(private) within the VPC."
}

variable "subnet_ip_range-4" {
  default     = "10.20.48.0/20"
  type        = string
  description = "CIDR block range for subnet 4(private) within the VPC."
}

variable "az-1"  {
  default     = "eu-central-1a"
  type        = string
  description = "Name of Availability Zone 1 within the region."
}

variable "az-2"  {
  default     = "eu-central-1b"
  type        = string
  description = "Name of Availability Zone 2 within the region."
}