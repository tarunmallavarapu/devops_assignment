variable "vpc_environment" {
  default = "assignment"
  
}
variable "vpc_name" {
  default = "assignment_vpc"
}

variable "app_cidr" {
    default = "10.0.0.0/16"
}

variable "vpc_public_subnets" {
  type = map(string)
  default = {ap-northeast-2a = "10.0.11.0/24",
             ap-northeast-2b = "10.0.12.0/24"}
}

variable "vpc_app_subnets" {
  type = map(string)
  default = {ap-northeast-2a = "10.0.1.0/24",
             ap-northeast-2b = "10.0.2.0/24"}
}

variable "app_ami" {
  default = "ami-083e69acfa4b35b6f"
}

variable "assign_ami" {
  default = "ami-00dab80918a1fa50d"
}
