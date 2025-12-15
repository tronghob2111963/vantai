# 💰 Railway Free Tier - Thông tin chi tiết

## 🎁 Railway Free Tier (2024)

### Tín dụng miễn phí

1. **$5 tín dụng** trong **30 ngày đầu** (trial period)
   - Dùng để test và deploy
   - Sau 30 ngày hoặc hết $5 thì chuyển sang free tier

2. **$1 tín dụng/tháng** (sau trial)
   - Mỗi tháng nhận $1 mới
   - **KHÔNG tích lũy** qua các tháng
   - Đủ để chạy 1-2 services nhỏ

### Giới hạn Free Tier

| Tài nguyên | Giới hạn |
|------------|----------|
| **Projects** | Tối đa **1 project** |
| **Services** | Tối đa **3 services** mỗi project |
| **RAM** | **0.5 GB** mỗi service |
| **vCPU** | **1 vCPU** mỗi service |
| **Storage** | **0.5 GB** volume storage |
| **Bandwidth** | Không giới hạn (trong phạm vi $1/tháng) |

### Chi phí sử dụng (tính theo $1/tháng)

**Ví dụ với $1/tháng:**
- **MySQL Database**: ~$0.10-0.20/tháng (tùy usage)
- **Backend Service**: ~$0.30-0.50/tháng (0.5GB RAM)
- **Frontend Service**: ~$0.20-0.30/tháng (0.5GB RAM)

**Tổng**: Có thể chạy **2-3 services** với $1/tháng nếu optimize tốt.

---

## 📊 So sánh Railway vs Render Free Tier

| Tính năng | Railway Free | Render Free |
|-----------|--------------|-------------|
| **Tín dụng** | $1/tháng | 750 giờ/tháng |
| **Projects** | 1 project | Không giới hạn |
| **Services** | 3 services/project | Không giới hạn |
| **RAM/Service** | 0.5 GB | 512 MB |
| **Sleep** | ❌ Không sleep | ✅ Sleep sau 15 phút |
| **MySQL** | ✅ Có sẵn | ❌ Chỉ PostgreSQL |
| **Docker** | ✅ Hỗ trợ tốt | ✅ Hỗ trợ tốt |
| **Database** | ✅ MySQL, PostgreSQL, MongoDB | ✅ Chỉ PostgreSQL |

---

## 💡 Kế hoạch sử dụng Free Tier hiệu quả

### Option 1: Tất cả trên Railway (Khuyến nghị)

```
Railway Project ($1/tháng):
├── MySQL Database (0.5GB RAM)     ~$0.15/tháng
├── Backend Service (0.5GB RAM)     ~$0.40/tháng  
└── Frontend Service (0.5GB RAM)    ~$0.25/tháng
─────────────────────────────────────────────────
Tổng: ~$0.80/tháng ✅ (trong $1 free)
```

**Ưu điểm:**
- ✅ Tất cả trong 1 project
- ✅ Không sleep (khác Render)
- ✅ MySQL native support
- ✅ Dễ quản lý

**Nhược điểm:**
- ⚠️ Chỉ 1 project
- ⚠️ Cần optimize để fit trong $1/tháng

### Option 2: Hybrid (Railway MySQL + Render Services)

```
Railway:
└── MySQL Database                  ~$0.15/tháng

Render:
├── Backend Service (Docker)        Free (750h)
└── Frontend Service (Docker)       Free (750h)
```

**Ưu điểm:**
- ✅ Tận dụng free tier cả 2 platforms
- ✅ MySQL trên Railway (không cần migrate)
- ✅ Backend/Frontend free trên Render

**Nhược điểm:**
- ⚠️ Render services sẽ sleep sau 15 phút
- ⚠️ Quản lý 2 platforms

### Option 3: Tất cả trên Render

```
Render:
├── Backend Service (Docker)        Free
├── Frontend Service (Docker)       Free
└── PostgreSQL Database             Free
```

**Ưu điểm:**
- ✅ Hoàn toàn miễn phí
- ✅ Tất cả trong 1 platform

**Nhược điểm:**
- ⚠️ Cần migrate MySQL → PostgreSQL
- ⚠️ Services sleep sau 15 phút

---

## 🎯 Khuyến nghị cho dự án PTCMSS

### Nếu muốn hoàn toàn free:

**Option A: Railway cho tất cả** (nếu fit trong $1/tháng)
- MySQL Database trên Railway
- Backend + Frontend trên Railway
- **Tổng**: ~$0.80-1.00/tháng (trong $1 free)

**Option B: Hybrid** (khuyến nghị)
- MySQL trên Railway (~$0.15/tháng)
- Backend + Frontend trên Render (free)
- **Tổng**: ~$0.15/tháng (rất rẻ!)

### Nếu muốn không sleep:

**Railway Hobby Plan** - $5/tháng
- $5 tín dụng/tháng
- Không sleep
- Nhiều projects hơn
- Nhiều resources hơn

---

## 📝 Lưu ý quan trọng

### Railway Free Tier

1. **$1/tháng không tích lũy**
   - Nếu không dùng hết, sẽ mất
   - Reset về $1 mỗi tháng

2. **1 project duy nhất**
   - Chỉ có thể tạo 1 project
   - Có thể có nhiều services trong 1 project

3. **0.5GB RAM/service**
   - Đủ cho MySQL, Backend, Frontend nhỏ
   - Có thể cần optimize nếu app lớn

4. **Cần verify GitHub**
   - Phải kết nối GitHub để deploy code
   - Nếu không verify, chỉ deploy được database

### Render Free Tier

1. **750 giờ/tháng**
   - Nếu chạy 2 services = 1500 giờ total
   - Đủ cho 1 service chạy 24/7

2. **Sleep sau 15 phút**
   - Services sẽ sleep nếu không có traffic
   - Wake up mất 30-60 giây

3. **Không giới hạn projects**
   - Có thể tạo nhiều projects

---

## 💰 Upgrade Plans

### Railway

| Plan | Giá | Tín dụng | Projects | Services |
|------|-----|----------|----------|----------|
| **Free** | $0 | $1/tháng | 1 | 3 |
| **Hobby** | $5/tháng | $5/tháng | 5 | Không giới hạn |
| **Pro** | $20/tháng | $20/tháng | Không giới hạn | Không giới hạn |

### Render

| Plan | Giá | Giờ/tháng | Sleep |
|------|-----|-----------|-------|
| **Free** | $0 | 750h | Có |
| **Starter** | $7/tháng | Không giới hạn | Không |

---

## ✅ Kết luận

**Railway Free Tier:**
- ✅ $1/tháng (không tích lũy)
- ✅ 1 project, 3 services
- ✅ 0.5GB RAM/service
- ✅ Không sleep
- ✅ MySQL native support

**So với Render:**
- Railway: Tốt hơn cho MySQL, không sleep
- Render: Tốt hơn cho số lượng services, hoàn toàn free

**Khuyến nghị:**
- **Hybrid**: MySQL Railway + Backend/Frontend Render
- Hoặc: **Tất cả Railway** nếu fit trong $1/tháng

---

**Tóm lại: Railway free tier = $1/tháng, đủ để chạy 2-3 services nhỏ!** 🚀

