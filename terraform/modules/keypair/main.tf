# Variables
variable "key_name" {
    type = string
    description = "EC2 key pair name"
}

variable "public_key_path" {
    type = string
    description = "Path to local public key file (if load key from existing local)"
    default = ""
}

resource "aws_key_pair" "main" {
    count = length(var.public_key_path) > 0 ? 1 : 0  # If public key path is provided, new key pair uploaded from local file path
    key_name = var.key_name
    public_key = file(var.public_key_path)
}

