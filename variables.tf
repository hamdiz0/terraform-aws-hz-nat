variable "ami_id" {
  type    = string
  default = null
  description = "The ami id to use for the nat instance, the module will default to the latest Amazon Linux 2023 ami if not provided"
}

variable "instance_type" {
  type    = string
  default = "t4g.micro"
  description = "The instance type to use for the nat instance"
}

variable "map_subnet_rtbs" {
  type = list(tuple([string, list(string)]))
  description = "A list of tuples each consisting of a public subnet id and a list of private route table ids to associate with the nat instance"
}

variable "vpc_id" {
  type = string
  description = "The vpc id used mainly for security group creation"
}

variable "use_script" {
  type = bool
  default = true
  description = "Whether to use the user data script or not (if a custom NAT AMI is used this should be set to false to avoid configuration conflicts)"
}

variable "use_ssh" {
  description = "whether to allow SSH access"
  type        = bool
  default     = false
}

variable "key_name" {
  description = "SSH key name for instances (only used if use_ssh is true)"
  type        = string
  default     = null
  validation {
    condition     = var.key_name == null || var.use_ssh == true
    error_message = "key_name can only be specified when use_ssh is true."
  }
}