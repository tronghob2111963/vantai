# ⚡ Quick Start - Deploy lên VPS

Hướng dẫn nhanh deploy PTCMSS lên VPS trong 15 phút.

## 🚀 5 Bước Cơ Bản

### 1. Thuê VPS (2 phút)
- Đăng ký [DigitalOcean](https://digitalocean.com) hoặc [Vultr](https://vultr.com)
- Tạo Droplet: Ubuntu 22.04, $6/tháng
- Lưu IP address

### 2. SSH vào VPS (1 phút)
```bash
ssh root@your-vps-ip
```

### 3. Cài Docker (3 phút)
```bash
apt update && apt upgrade -y
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
apt install docker-compose -y
```

### 4. Clone và chạy (5 phút)
```bash
cd /opt
git clone https://github.com/your-username/your-repo.git
cd your-repo/PTCMSS

# Tạo .env
nano .env
# Copy nội dung từ .env.example và sửa

# Chạy
docker-compose up -d
```

### 5. Cấu hình Firewall (2 phút)
```bash
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 8080/tcp
ufw enable
```

## ✅ Done!

Truy cập:
- Frontend: `http://your-vps-ip:5173`
- Backend: `http://your-vps-ip:8080`

## 📚 Chi tiết

Xem [HUONG_DAN_DEPLOY_VPS_CLOUD.md](./HUONG_DAN_DEPLOY_VPS_CLOUD.md)





