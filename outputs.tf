output "api_url" {
  value       = "http://${aws_instance.currency_converter.public_ip}:3009/convert"
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

output "check user-data" {
  value       = "รัน ssh แล้ว cat /var/log/user-data.log"
  description = "ดู error ต่าง ๆ"
}

output "check app-data" {
  value       = "รัน ssh แล้ว cat /devops68-currency-converter/app.log"
  description = "ดู log ของแอป"
}
