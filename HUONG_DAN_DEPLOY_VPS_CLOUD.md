# 🖥️ Hướng dẫn Deploy lên VPS/Cloud Server

## 🎯 VPS/Cloud là gì?

**VPS (Virtual Private Server)** = Máy chủ ảo riêng của bạn
- ✅ Có quyền root/admin
- ✅ Cài đặt bất kỳ gì bạn muốn
- ✅ Chạy nhiều services cùng lúc
- ✅ Không bị giới hạn như Render/Railway

**Cloud Server** = Tương tự VPS, nhưng trên nền tảng cloud (AWS, Google Cloud, Azure, DigitalOcean, etc.)

---

## 💰 So sánh VPS vs Render/Railway

| Tính năng | VPS/Cloud | Render/Railway |
|-----------|-----------|----------------|
| **Quyền kiểm soát** | ✅ Full control | ⚠️ Giới hạn |
| **Chi phí** | $5-20/tháng | Free - $7/tháng |
| **Cài đặt** | ✅ Tự do | ⚠️ Giới hạn |
| **Docker Compose** | ✅ Chạy được | ❌ Không hỗ trợ |
| **MySQL** | ✅ Tự cài | ⚠️ Managed service |
| **Sleep** | ✅ Không sleep | ⚠️ Free tier sleep |
| **Quản lý** | ⚠️ Tự quản lý | ✅ Tự động |
| **Backup** | ⚠️ Tự setup | ✅ Tự động |

---

## 🚀 Các Nhà Cung Cấp VPS/Cloud Phổ Biến

### 1. **DigitalOcean** (Khuyến nghị cho người mới)
- 💰 **$6/tháng** (1GB RAM, 1 vCPU)
- ✅ Dễ dùng, UI đẹp
- ✅ Có sẵn Docker image
- ✅ Tài liệu tốt

### 2. **Vultr**
- 💰 **$6/tháng** (1GB RAM, 1 vCPU)
- ✅ Nhiều location
- ✅ Giá rẻ

### 3. **Linode** (Akamai)
- 💰 **$5/tháng** (1GB RAM, 1 vCPU)
- ✅ Uy tín, ổn định

### 4. **AWS EC2** (Amazon)
- 💰 **Free tier 12 tháng**, sau đó ~$10/tháng
- ✅ Mạnh mẽ, nhiều tính năng
- ⚠️ Phức tạp hơn

### 5. **Google Cloud Platform**
- 💰 **Free tier $300 credit**
- ✅ Mạnh mẽ
- ⚠️ Phức tạp

### 6. **Azure** (Microsoft)
- 💰 **Free tier $200 credit**
- ✅ Tích hợp tốt với Microsoft tools

### 7. **VPS Việt Nam** (FPT, Viettel, VNPT)
- 💰 **200k-500k/tháng**
- ✅ Gần, tốc độ nhanh trong nước
- ⚠️ Giới hạn bandwidth quốc tế

---

## 🐳 Deploy với Docker Compose trên VPS

### Bước 1: Thuê VPS

1. Đăng ký tài khoản (ví dụ: DigitalOcean)
2. Tạo Droplet/Server:
   - **OS**: Ubuntu 22.04 LTS
   - **Plan**: $6/tháng (1GB RAM) hoặc $12/tháng (2GB RAM)
   - **Region**: Singapore (gần Việt Nam)
   - **Authentication**: SSH key (khuyến nghị) hoặc Password

### Bước 2: Kết nối VPS

```bash
# SSH vào VPS
ssh root@your-vps-ip
# hoặc
ssh root@your-vps-domain
```

### Bước 3: Cài đặt Docker và Docker Compose

```bash
# Update system
apt update && apt upgrade -y

# Cài Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Cài Docker Compose
apt install docker-compose -y

# Kiểm tra
docker --version
docker-compose --version
```

### Bước 4: Upload code lên VPS

**Cách 1: Clone từ GitHub** (Khuyến nghị)

```bash
# Cài Git
apt install git -y

# Clone repository
cd /opt
git clone https://github.com/your-username/your-repo.git
cd your-repo/PTCMSS
```

**Cách 2: Upload bằng SCP**

```bash
# Từ máy local
scp -r ./PTCMSS root@your-vps-ip:/opt/ptcmss
```

**Cách 3: Upload bằng SFTP** (FileZilla, WinSCP)

### Bước 5: Cấu hình Environment Variables

```bash
cd /opt/your-repo/PTCMSS

# Tạo file .env
nano .env
```

Thêm vào file `.env`:
```env
# MySQL
MYSQL_ROOT_PASSWORD=your-secure-password
MYSQL_DATABASE=ptcmss_db
MYSQL_PORT=3306

# Backend
SPRING_DATASOURCE_USERNAME=root
SPRING_DATASOURCE_PASSWORD=your-secure-password
SPRING_PROFILES_ACTIVE=production
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=your-email@gmail.com
MAIL_PASSWORD=your-app-password

# Frontend
VITE_API_BASE=http://your-vps-ip:8080
# hoặc nếu có domain
VITE_API_BASE=https://api.yourdomain.com
```

### Bước 6: Chạy Docker Compose

```bash
# Build và start tất cả services
docker-compose up -d

# Xem logs
docker-compose logs -f

# Kiểm tra services
docker-compose ps
```

### Bước 7: Cấu hình Firewall

```bash
# Cài UFW (firewall)
apt install ufw -y

# Cho phép SSH
ufw allow 22/tcp

# Cho phép HTTP/HTTPS
ufw allow 80/tcp
ufw allow 443/tcp

# Cho phép Backend port (nếu cần)
ufw allow 8080/tcp

# Bật firewall
ufw enable
```

### Bước 8: Cấu hình Domain (Optional)

Nếu có domain:

1. **Cấu hình DNS**:
   - A record: `@` → VPS IP
   - A record: `api` → VPS IP
   - A record: `www` → VPS IP

2. **Cài Nginx Reverse Proxy**:

```bash
apt install nginx -y

# Tạo config cho frontend
nano /etc/nginx/sites-available/frontend
```

```nginx
server {
    listen 80;
    server_name yourdomain.com www.yourdomain.com;

    location / {
        proxy_pass http://localhost:5173;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

```bash
# Tạo config cho backend
nano /etc/nginx/sites-available/backend
```

```nginx
server {
    listen 80;
    server_name api.yourdomain.com;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

```bash
# Enable sites
ln -s /etc/nginx/sites-available/frontend /etc/nginx/sites-enabled/
ln -s /etc/nginx/sites-available/backend /etc/nginx/sites-enabled/

# Test config
nginx -t

# Reload
systemctl reload nginx
```

3. **Cài SSL với Let's Encrypt**:

```bash
apt install certbot python3-certbot-nginx -y
certbot --nginx -d yourdomain.com -d www.yourdomain.com
certbot --nginx -d api.yourdomain.com
```

---

## 🔧 Quản Lý Services

### Xem logs

```bash
# Tất cả services
docker-compose logs -f

# Service cụ thể
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f mysql
```

### Restart services

```bash
# Restart tất cả
docker-compose restart

# Restart service cụ thể
docker-compose restart backend
```

### Stop/Start

```bash
# Stop
docker-compose stop

# Start
docker-compose start

# Stop và xóa containers
docker-compose down

# Stop, xóa containers và volumes
docker-compose down -v
```

### Update code

```bash
# Pull code mới
cd /opt/your-repo
git pull origin main

# Rebuild và restart
cd PTCMSS
docker-compose up -d --build
```

---

## 🔒 Bảo Mật

### 1. Đổi SSH port (tùy chọn)

```bash
nano /etc/ssh/sshd_config
# Đổi Port 22 thành Port 2222

systemctl restart sshd
ufw allow 2222/tcp
```

### 2. Tắt root login (khuyến nghị)

```bash
# Tạo user mới
adduser deploy
usermod -aG sudo deploy

# Copy SSH key
mkdir -p /home/deploy/.ssh
cp ~/.ssh/authorized_keys /home/deploy/.ssh/
chown -R deploy:deploy /home/deploy/.ssh

# Tắt root login
nano /etc/ssh/sshd_config
# Đổi: PermitRootLogin no

systemctl restart sshd
```

### 3. Setup Firewall đúng cách

```bash
# Chỉ cho phép ports cần thiết
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp    # SSH
ufw allow 80/tcp     # HTTP
ufw allow 443/tcp   # HTTPS
ufw enable
```

### 4. Backup Database

```bash
# Tạo script backup
nano /opt/backup-db.sh
```

```bash
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/opt/backups"
mkdir -p $BACKUP_DIR

docker-compose exec -T mysql mysqldump -uroot -p$MYSQL_ROOT_PASSWORD ptcmss_db > $BACKUP_DIR/backup_$DATE.sql

# Xóa backup cũ hơn 7 ngày
find $BACKUP_DIR -name "backup_*.sql" -mtime +7 -delete
```

```bash
chmod +x /opt/backup-db.sh

# Thêm vào crontab (backup mỗi ngày lúc 2h sáng)
crontab -e
# Thêm dòng:
0 2 * * * /opt/backup-db.sh
```

---

## 📊 Monitoring

### Cài đặt monitoring tools

```bash
# Cài htop để monitor
apt install htop -y
htop

# Xem disk usage
df -h

# Xem memory
free -h

# Xem docker stats
docker stats
```

---

## 💰 Chi Phí Ước Tính

### VPS cơ bản (đủ cho dự án nhỏ)

- **DigitalOcean**: $6/tháng (1GB RAM)
- **Vultr**: $6/tháng (1GB RAM)
- **Linode**: $5/tháng (1GB RAM)

### VPS khuyến nghị (cho production)

- **DigitalOcean**: $12/tháng (2GB RAM, 1 vCPU)
- **Vultr**: $12/tháng (2GB RAM, 1 vCPU)

### Tổng chi phí/tháng

- VPS: $6-12/tháng
- Domain (nếu có): $10-15/năm (~$1/tháng)
- **Tổng**: ~$7-13/tháng

---

## ✅ Checklist Deploy VPS

- [ ] Thuê VPS (DigitalOcean/Vultr/etc.)
- [ ] SSH vào VPS
- [ ] Cài Docker và Docker Compose
- [ ] Clone/Upload code
- [ ] Tạo file .env
- [ ] Chạy docker-compose up -d
- [ ] Cấu hình firewall
- [ ] Cấu hình domain (nếu có)
- [ ] Cài SSL (Let's Encrypt)
- [ ] Setup backup tự động
- [ ] Test ứng dụng

---

## 🆚 Khi Nào Dùng VPS vs Render/Railway?

### Dùng VPS khi:
- ✅ Cần full control
- ✅ Muốn chạy Docker Compose
- ✅ Có nhiều services
- ✅ Cần tùy chỉnh nhiều
- ✅ Có kinh nghiệm quản lý server

### Dùng Render/Railway khi:
- ✅ Muốn đơn giản, nhanh
- ✅ Không muốn quản lý server
- ✅ Dự án nhỏ, prototype
- ✅ Muốn free tier
- ✅ Không có kinh nghiệm server

---

## 🎯 Kết Luận

**VPS/Cloud = Server riêng của bạn**
- ✅ Đem code lên và chạy
- ✅ Full control
- ✅ Chạy được Docker Compose
- ✅ Không bị giới hạn
- ⚠️ Tự quản lý, backup, bảo mật

**Khuyến nghị:**
- **Người mới**: Render/Railway (dễ hơn)
- **Có kinh nghiệm**: VPS (linh hoạt hơn)
- **Production**: VPS + Managed Database (tốt nhất)

---

**Chúc bạn deploy thành công! 🚀**



