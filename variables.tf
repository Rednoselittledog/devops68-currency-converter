# AWS Region
variable "aws_region" {
  description = "AWS Region ที่ต้องการ Deploy"
  type        = string
  default     = "ap-southeast-2"
}

# SSH Key Name
variable "key_name" {
  description = "ชื่อของ Key Pair สำหรับ SSH"
  type        = string
  default     = "DevOpsQuiz-2"
}

# Instance Type
variable "instance_type" {
  description = "ขนาดของ EC2 Instance"
  type        = string
  default     = "t3.micro"
}
