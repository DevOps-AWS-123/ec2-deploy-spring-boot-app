// Define VPC CIDR block
variable "aws_vpc" {
  description = "CIDR block for the VPC"
  type        = string
}

// Define public subnet CIDR block
variable "public_subnet" {
  description = "CIDR block for the public subnet"
  type        = string
}

// Define private subnet CIDR block
variable "private_subnet" {
  description = "CIDR block for the private subnet"
  type        = string
}

// Define AWS region
variable "aws_region" {
  description = "The AWS region to deploy the resources in"
  type        = string
  default     = "us-west-2"  // Optional default
}

// Define tags for the resources
variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {
    Environment = "dev"
    Project     = "VPC-Dynamic"
  }
}

variable "instance_type" {
  description = "Type of EC2 instance"
  type        = string
  default     = "t2.micro"  # Suitable for free-tier usage
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "key_name" {
  description = "Name of the key pair to connect to EC2"
  type        = string
}

variable "public_subnet_id" {
  description = "Public Subnet ID where EC2 will be launched"
  type        = string
}
