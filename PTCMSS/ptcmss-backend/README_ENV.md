# 🔐 HƯỚNG DẪN CẤU HÌNH ENVIRONMENT VARIABLES

## 📍 Vị trí file `.env`

File `.env` nên đặt ở **root của project** (cùng cấp với `pom.xml`):

```
ptcmss-backend/
├── pom.xml
├── .env          ← Đặt ở đây
├── .env.example  ← Template (có thể commit)
├── src/
└── ...
```

---

## 🚀 CÁCH SỬ DỤNG

### **1. Tạo file `.env` từ template:**

```bash
# Copy template
cp .env.example .env

# Hoặc tạo mới
touch .env
```

### **2. Điền thông tin thực tế vào `.env`:**

```env
# VietQR API Credentials
VIETQR_CLIENT_ID=your_actual_client_id
VIETQR_API_KEY=your_actual_api_key

# Payment Bank Account
PAYMENT_BANK_CODE=970418
PAYMENT_BANK_ACCOUNT_NUMBER=1234567890
PAYMENT_BANK_ACCOUNT_NAME=CONG TY PTCMSS
```

### **3. Spring Boot sẽ tự động đọc:**

Spring Boot 2.4+ tự động đọc biến môi trường từ:
- System environment variables
- `.env` file (nếu dùng plugin dotenv-java)
- `application.yml` với syntax `${VAR_NAME:default_value}`

---

## ⚠️ LƯU Ý QUAN TRỌNG

### ✅ **NÊN LÀM:**
- ✅ Tạo file `.env` từ `.env.example`
- ✅ Thêm `.env` vào `.gitignore` (đã có sẵn)
- ✅ Commit `.env.example` lên Git (template)
- ✅ Dùng biến môi trường trong `application.yml`

### ❌ **KHÔNG NÊN:**
- ❌ Commit file `.env` lên Git
- ❌ Hardcode API key trong code
- ❌ Để API key trong `application.yml` dạng plain text

---

## 🔧 CẤU HÌNH TRONG `application.yml`

Đã được cấu hình sẵn:

```yaml
vietqr:
  client-id: ${VIETQR_CLIENT_ID:}  # Đọc từ .env hoặc environment variable
  api-key: ${VIETQR_API_KEY:}      # Đọc từ .env hoặc environment variable
```

**Syntax:** `${VAR_NAME:default_value}`
- Nếu có biến môi trường → dùng giá trị đó
- Nếu không có → dùng `default_value` (có thể để trống)

---

## 🐳 DOCKER / PRODUCTION

### **Local Development:**
- Dùng file `.env` trong root project

### **Docker:**
```yaml
# docker-compose.yml
services:
  backend:
    environment:
      - VIETQR_CLIENT_ID=${VIETQR_CLIENT_ID}
      - VIETQR_API_KEY=${VIETQR_API_KEY}
```

### **Production (AWS/Azure/GCP):**
- Dùng **Secret Manager** hoặc **Environment Variables** của platform
- Không dùng file `.env` trên server

---

## 📝 CHECKLIST

- [ ] Tạo file `.env` từ `.env.example`
- [ ] Điền `VIETQR_CLIENT_ID` và `VIETQR_API_KEY` thực tế
- [ ] Kiểm tra `.gitignore` đã có `.env`
- [ ] Test ứng dụng đọc được biến môi trường
- [ ] Không commit `.env` lên Git

---

## 🔗 TÀI LIỆU THAM KHẢO

- [Spring Boot Externalized Configuration](https://docs.spring.io/spring-boot/docs/current/reference/html/features.html#features.external-config)
- [VietQR API Documentation](https://www.vietqr.io/danh-sach-api/link-tao-ma-nhanh/api-tao-ma-qr/)

