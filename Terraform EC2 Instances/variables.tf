variable "rules" {
  description = "Rules that will be applied to the VPC"
  type = list(object({
    port        = number
    proto       = string
    cidr_blocks = list(string)
  }))
  default = [
    {
      port        = 80
      proto       = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      port        = 22
      proto       = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      port        = 3689
      proto       = "tcp"
      cidr_blocks = ["6.7.8.9/32"]
    }
  ]
}

variable "use_public_subnet" {
  type    = bool
  default = true
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "eu-north-1"
}

variable "instance_type" {
  description = "Type of Instance to be used"
  type        = string
  default     = "t3.micro"
}

variable "instance_count" {
  description = "Number of instances"
  type        = number
  default     = 3
}

variable "availability_zone_index" {
  description = "Select which AZ to deploy to"
  type        = number
  default     = 0
}
