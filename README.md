# Currency Converter API

## 1. การติดตั้ง Terraform

### macOS
```bash
# ใช้ Homebrew
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

# ตรวจสอบการติดตั้ง
terraform version
```

### Windows
```powershell
# ใช้ Chocolatey
choco install terraform

# หรือดาวน์โหลดจาก https://www.terraform.io/downloads
# แล้วเพิ่ม path ใน Environment Variables

# ตรวจสอบการติดตั้ง
terraform version
```

### Linux (Ubuntu/Debian)
```bash
# เพิ่ม HashiCorp GPG key
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

# เพิ่ม repository
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

# ติดตั้ง Terraform
sudo apt update && sudo apt install terraform

# ตรวจสอบการติดตั้ง
terraform version
```

---

## 2. การติดตั้งและตั้งค่า AWS CLI

### ติดตั้ง AWS CLI

#### macOS
```bash
# ใช้ Homebrew
brew install awscli

# หรือใช้ installer
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /
```

#### Windows
```powershell
# ดาวน์โหลดและติดตั้งจาก
# https://awscli.amazonaws.com/AWSCLIV2.msi
```

#### Linux
```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

### ตั้งค่า AWS Credentials

1. เข้าไปที่ [AWS Console](https://console.aws.amazon.com/)
2. ไปที่ IAM → Users → สร้าง User ใหม่หรือเลือก User ที่มีอยู่
3. สร้าง Access Key (Security credentials → Create access key)
4. บันทึก Access Key ID และ Secret Access Key

จากนั้นรัน:
```bash
aws configure
```

ใส่ข้อมูลดังนี้:
```
AWS Access Key ID: [YOUR_ACCESS_KEY_ID]
AWS Secret Access Key: [YOUR_SECRET_ACCESS_KEY]
Default region name: ใส่ region ดูที่มุมขวาบนของ aws console ในเว็บ (เช่น ap-southeast-2)
Default output format: กด enter เลยไม่ต้องกรอก
```

ตรวจสอบการตั้งค่า:
```bash
aws sts get-caller-identity
```

---

## 3. การ Clone โปรเจกต์

```bash
git clone https://github.com/Rednoselittledog/devops68-currency-converter.git
cd devops68-currency-converter
```

---

## 4. การปรับแต่งค่า Configuration (ถ้าต้องการ)

แก้ไขไฟล์ [variables.tf](variables.tf) ตามความต้องการ:

```hcl
variable "aws_region" {
  default = "ap-southeast-2"  # เปลี่ยน region ให้ตรงกับที่เราลงไว้ใน aws configure
}

variable "key_name" {
  default = "DevOpsQuiz-2"    # เปลี่ยนชื่อ key ได้
}

variable "instance_type" {
  default = "t3.micro"        # เปลี่ยนขนาด instance ได้
}
```

เสร็จแล้วแก้ไขไฟล์ [main.tf](main.tf) บรรทัดที่ 66 ปรับ ami ตาม region/instance_type ดูได้จาก lauch instance แล้วเลือก ubuntu เลื่อนไปล่างสุดหาคำว่า ami

---

## 5. การ Deploy ด้วย Terraform

### 5.1 Initialize Terraform
```bash
terraform init
```
คำสั่งนี้จะดาวน์โหลด provider ที่จำเป็น (AWS)

### 5.2 ตรวจสอบ Plan
```bash
terraform plan
```
แสดงสิ่งที่ Terraform จะสร้างหรือเปลี่ยนแปลง

### 5.3 Apply Configuration
```bash
terraform apply
```
พิมพ์ `yes` เพื่อยืนยันการสร้าง infrastructure

การ apply จะใช้เวลาประมาณ 2-5 นาที โดยจะสร้าง:
- EC2 Instance (Ubuntu 22.04)
- Security Group (เปิด port 22, 80, 3009)
- SSH Key Pair (.pem file)
- ติดตั้ง Node.js และรันแอปพลิเคชันอัตโนมัติ

### 5.4 ดู Output
หลังจาก apply สำเร็จ จะเห็น output ดังนี้:
```
api_url = "http://[PUBLIC_IP]:3009/convert"
example_usage = "http://[PUBLIC_IP]:3009/convert?amount=100&from=USD&to=THB"
public_ip = "[PUBLIC_IP]"
ssh_command = "ssh -i DevOpsQuiz-2.pem ubuntu@[PUBLIC_IP]"
```

---

## 6. การใช้งาน API

### 6.1 รอให้แอปพลิเคชันเริ่มทำงาน
หลังจาก `terraform apply` สำเร็จ ต้องรอประมาณ **1-2 นาที** เพื่อให้ user-data script ติดตั้ง Node.js และรันแอปพลิเคชัน

### 6.2 อัตราแลกเปลี่ยนที่ใช้ในแอป
```javascript
{
  'USD': 1,
  'EUR': 0.92,
  'GBP': 0.79,
  'JPY': 149.50,
  'AUD': 1.53,
  'CAD': 1.36,
  'INR': 83.12
}
```

### 6.3 Format การเรียกใช้ API

API ใช้ HTTP GET method และรับ parameters ผ่าน query string:

**Format:**
```
http://[PUBLIC_IP]:3009/convert?amount=[จำนวนเงิน]&from=[สกุลเงินต้นทาง]&to=[สกุลเงินปลายทาง]
```

**Parameters:**
- `amount` (required) - จำนวนเงินที่ต้องการแปลง (ตัวเลขเท่านั้น)
- `from` (required) - สกุลเงินต้นทาง (USD, EUR, GBP, JPY, AUD, CAD, INR)
- `to` (required) - สกุลเงินปลายทาง (USD, EUR, GBP, JPY, AUD, CAD, INR)

**หมายเหตุ:**
- สกุลเงินต้องเป็นตัวพิมพ์ใหญ่เท่านั้น
- ต้องระบุ parameter ทั้ง 3 ตัว ไม่งั้นจะ error

### 6.4 ทดสอบ API

#### ตัวอย่างที่ 1: แปลง USD เป็น EUR
```bash
curl "http://[YOUR_PUBLIC_IP]:3009/convert?amount=100&from=USD&to=EUR"
```

#### ตัวอย่างที่ 2: แปลง EUR เป็น JPY
```bash
curl "http://[YOUR_PUBLIC_IP]:3009/convert?amount=50&from=EUR&to=JPY"
```

#### ตัวอย่างที่ 3: ใช้ผ่าน Browser
เปิด browser แล้วเข้า:
```
http://[YOUR_PUBLIC_IP]:3009/convert?amount=100&from=USD&to=EUR
```

### 6.5 Format ของ Response

#### สำเร็จ:
```json
{
  "amount": 100,
  "from": "USD",
  "to": "EUR",
  "result": 92
}
```

#### ผิดพลาด (ขาด parameter):
```json
{
  "error": "Missing parameters : Convert undefined from USD to undefined"
}
```

#### ผิดพลาด (สกุลเงินไม่ถูกต้อง):
```json
{
  "error": "Invalid currency code"
}
```

---

## 7. การตรวจสอบและ Debugging

### 7.1 SSH เข้า EC2 Instance
```bash
ssh -i DevOpsQuiz-2.pem ubuntu@[YOUR_PUBLIC_IP]
```

### 7.2 ตรวจสอบ User Data Log
```bash
cat /var/log/user-data.log
```
ดู log การติดตั้ง Node.js และ dependencies

### 7.3 ตรวจสอบ Application Log
```bash
cat /home/ubuntu/devops68-currency-converter/app.log
```
ดู log การทำงานของแอปพลิเคชัน

### 7.4 ตรวจสอบ Process ที่กำลังรัน
```bash
ps aux | grep node
```

### 7.5 ตรวจสอบว่า API ทำงานหรือไม่
```bash
curl "localhost:3009/convert?amount=100&from=USD&to=EUR"
```

---

## 8. การลบ Infrastructure

เมื่อต้องการลบ resources ทั้งหมดที่สร้างไว้:

```bash
terraform destroy
```
พิมพ์ `yes` เพื่อยืนยัน

คำสั่งนี้จะลบ:
- EC2 Instance
- Security Group
- Key Pair บน AWS
- ไฟล์ .pem ในเครื่อง

---
