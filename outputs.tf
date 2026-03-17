output "api_url" {
  value       = "http://${aws_instance.currency_converter.public_ip}:3009"
  description = "URL ของ Currency Converter API"
}

output "example_usage" {
  value       = "http://${aws_instance.currency_converter.public_ip}:3009/convert?amount=100&from=USD&to=THB"
  description = "ตัวอย่างการใช้งาน API"
}

output "public_ip" {
  value       = aws_instance.currency_converter.public_ip
  description = "Public IP ของ EC2 Instance"
}

output "ssh_command" {
  value       = "ssh -i ${var.key_name}.pem ubuntu@${aws_instance.currency_converter.public_ip}"
  description = "คำสั่ง SSH เข้าเครื่อง"
}
