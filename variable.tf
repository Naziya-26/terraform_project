variable "aws_access_key" {
  description = "AWS Access Key"
}

variable "aws_secret_key" {
  description = "AWS Secret Access Key"
}

variable "region" {
  description = "AWS region"
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
}
variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}


variable "public_subnet_cidr_blocks" {
  description = "CIDR blocks for the public subnets"
  type        = list(string)
}
variable "public_subnet_name" {
  description = "Name of the public subnet"
  type        = string
}


variable "private_subnet_cidr_blocks" {
  description = "CIDR blocks for the private subnets"
  type        = list(string)
}
variable "private_subnet_name" {
  description = "Name of the private subnet"
  type        = string
}
variable "public_instance_name" {
  description = "Name of the public instance"
  type        = string
}
variable "private_instance_name" {
  description = "Name of the private instance"
  type        = string
  
}



variable "centos_ami" {
  description = "AMI ID for CentOS"
}
variable "public_instance_type" {
  description = "Instance type for the public subnet"
  type        = string
}

variable "private_instance_type" {
  description = "Instance type for the private subnet"
  type        = string
}

variable "public_instance_count" {
  description = "Number of instances to create in the public subnet"
  type        = number
}

variable "private_instance_count" {
  description = "Number of instances to create in the private subnet"
  type        = number
}
variable "instance_user_data" {
  description = "User data script for the instances"
  type        = string
  
}

variable "instance_user_data_private" {
  description = "User data script for the instances"
  type        = string
  
}
variable "ssh_port" {
  description = "SSH port"
  type        = number
 
}

variable "https_port" {
  description = "HTTPS port"
  type        = number
  
}

variable "http_port" {
  description = "HTTP port"
  type        = number
  
}

variable "docker_port" {
  description = "Docker port"
  type        = number
  
}

variable "cidr_blocks" {
  description = "List of CIDR blocks"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
variable "ssh_port_private" {
  description = "SSH port"
  type        = number

}