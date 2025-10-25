variable "region" {
  description = "AWS region for state backend resources"
  type        = string
}

 variable "project"      { 
  type = string 
}

variable "environment"  { 
  type = string 
}
 
variable "state_bucket" { 
  type = string 
}
