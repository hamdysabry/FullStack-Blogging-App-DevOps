variable "aws_region" {
  description = "AWS region to deploy the resources"
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS CLI profile name"
  default     = "myeksprofile"
}

variable "cluster_name" {
  description = "EKS Cluster name"
  default     = "blogging-eks"
}

variable "cluster_version" {
  description = "EKS Cluster version"
  default     = "1.29"
}

variable "node_instance_type" {
  description = "EC2 instance type for managed node group"
  default     = "t3.medium"
}

variable "my_ip" {
  description = "Your public IP to access EKS API server"
  default     = "156.221.65.212/32"
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  default     = "10.0.0.0/16"
}

variable "private_subnets" {
  description = "Private subnets CIDRs"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_subnets" {
  description = "Public subnets CIDRs"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}
