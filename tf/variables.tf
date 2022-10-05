variable "aws_region" {
  default = "us-east-1"
}

variable "shared_credentials_file" {
  default = "/home/savicloud/.aws/credentials"
}

variable "shared_credentials_file_profile" {
  default = "terraform"
}

variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_count" {
  description = "Number of subnets"
  type        = map(number)
  default = {
    public  = 1,
    private = 2
  }
}

variable "settings" {
  description = "Config"
  type        = map(any)
  default = {
    "database" = {
      allocated_storage   = 10            // in GB
      engine              = "mysql"       
      engine_version      = "8.0.27"      
      instance_class      = "db.t2.micro" 
      db_name             = "todo"    
      skip_final_snapshot = true
    },
    "web_app" = {
      count         = 1          // the number of EC2 instances
      instance_type = "t2.micro" // the EC2 instance
    }
  }
}

variable "public_subnet_cidr_blocks" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24",
    "10.0.4.0/24"
  ]
}

variable "private_subnet_cidr_blocks" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default = [
    "10.0.101.0/24",
    "10.0.102.0/24",
    "10.0.103.0/24",
    "10.0.104.0/24",
  ]
}

// Accessing .tfvars file for senstive data
variable "db_username" {
  description = "Database master user"
  type        = string
  sensitive   = true
}
variable "db_password" {
  description = "Database master user password"
  type        = string
  sensitive   = true
}