variable "python_version" {
  description = "Desired version of Python"
  default     = "3.7.2"
}

variable "git_version" {
  description = "Desired version of Git for Windows"
  default     = "2.21.0"
}

variable "windows_version" {
  description = "Version of Windows Server to use (options are 2008, 2012, 2016)"
  default     = "2016"
}

variable "aws_region" {
  description = "AWS Region"
  default     = "us-east-1"
}

variable "az_to_find_subnet" {
  description = "Used to find the default subnet (ignored if subnet_id is provided)"
  default     = "us-east-1c"
}

variable "subnet_id" {
  description = "ID of subnet to use (or default if blank)"
  default     = ""
}

variable "instance_profile" {
  description = "IAM profile used for launching the instance"
  default     = ""
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.medium"
}

variable "name_prefix" {
  description = "Prefix used in naming and tagging resources"
  default     = "matchwaker"
}

variable "wam_args" {
  description = "Arguments passed to Watchmaker"
  default     = "-n -e dev"
}

variable "git_repo" {
  description = "Github repo username to get Watchmaker"
  default     = "plus3it"
}

variable "git_ref" {
  description = "Github Watchmaker repo ref to checkout"
  default     = "master"
}
