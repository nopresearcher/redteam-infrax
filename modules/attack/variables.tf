variable "enable_ubuntu" {
  description = "If set to true, Ubuntu will be deployed"
  type        = bool
  default     = false
}

variable "enable_kali" {
  description = "If set to true, Kali will be deployed"
  type        = bool
  default     = true
}

variable "enable_windows" {
  description = "If set to true, Windows will be deployed"
  type        = bool
  default     = true
}

variable "path_to_private_key" { 
    description = "private key file path"
    default     = "key.pem"
}

variable "path_to_public_key" { 
    description = "public key file path"
    default     = "key.pem.pub"
}

variable "windows_ami" { 
    type        = string
    default     = "ami-032c2c4b952586f02"
    description = "Windows_Server-2019-English-Full-Base-2020.08.12"
}

variable "win_username" { 
    type        = string
    default     = "Administrator"
    description = "Windows Administrator user to login as."
}

variable "win_password" { 
    type        = string
    default     = "Hacks##allThing##2020"
    description = "Windows Administrator password to login as."
}