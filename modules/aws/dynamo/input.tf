variable "region" {
  default = "eu-west-1"
}

variable "env" {
  default = "demo"
}

variable "write_capacity" {
  default = "10"
}

variable "read_capacity" {
  default = "10"
}

variable "point_in_time_recovery_enabled" {
  default = false
}

variable "aws_backup" {
    default = false
}
