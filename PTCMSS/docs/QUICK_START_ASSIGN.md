# Hướng dẫn nhanh: Gán Tài xế & Xe

## Cách sử dụng

### 1. Mở popup gán chuyến
```javascript
// Từ component điều phối
<AssignDriverDialog
  open={true}
  order={{
    tripId: 456,
    bookingId: 123,
    // ... thông tin khác
  }}
  onClose={() => setOpen(false)}
  onAssigned={(result) => {
    console.log('Gán thành công:', result);
    // Reload danh sách
  }}
/>
```

### 2. Gán tự động (Auto-assign)
- Click nút **"Tự động gán (Auto-assign)"**
- Hệ thống tự chọn cặp tài xế + xe tốt nhất
- Dựa trên điểm công bằng (fairness score)

### 3. Gán thủ công (Manual)
- Chọn tài xế từ dropdown (chỉ hiện ứng viên hợp lệ)
- Chọn xe từ dropdown (chỉ hiện xe rảnh)
- Click **"Xác nhận gán chuyến"**

## API nhanh

### Lấy gợi ý
```bash
curl -X GET "http://localhost:8080/api/dispatch/trips/456/suggestions" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Gán tự động
```bash
curl -X POST "http://localhost:8080/api/dispatch/assign" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "bookingId": 123,
    "tripIds": [456],
    "autoAssign": true
  }'
```

### Gán thủ công
```bash
curl -X POST "http://localhost:8080/api/dispatch/assign" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "bookingId": 123,
    "tripIds": [456],
    "driverId": 101,
    "vehicleId": 55,
    "autoAssign": false
  }'
```

## Quy tắc công bằng (Fairness)

**Điểm thấp = Ưu tiên cao**

```
Score = (chuyến_hôm_nay × 40) + (chuyến_tuần × 30) + (chuyến_gần_đây × 30)
```

**Ví dụ**:
- Tài xế A: 2 chuyến hôm nay, 8 tuần, 5 gần → Score = 470
- Tài xế B: 1 chuyến hôm nay, 5 tuần, 3 gần → Score = 280 ✅ **Chọn**

## Lọc ứng viên

### Tài xế hợp lệ
✅ Cùng chi nhánh  
✅ Không nghỉ phép  
✅ Bằng lái còn hạn  
✅ Không trùng giờ  

### Xe hợp lệ
✅ Cùng chi nhánh  
✅ Trạng thái AVAILABLE  
✅ Không trùng giờ  

## Troubleshooting

### Không có gợi ý
- Kiểm tra có tài xế/xe trong chi nhánh không
- Kiểm tra thời gian chuyến có hợp lệ không
- Xem log backend: `[Dispatch] No eligible driver/vehicle found`

### Gán thất bại
- Kiểm tra tài xế/xe còn rảnh không (có thể đã bị gán)
- Kiểm tra quyền: cần role ADMIN/MANAGER/COORDINATOR
- Xem response error message

### Điểm công bằng không đúng
- Kiểm tra dữ liệu trips trong database
- Verify startTime của trips
- Check logic trong `evaluateDriverCandidates()`

## Xem thêm
- [Tài liệu đầy đủ](./assign-driver-vehicle-feature.md)
- [API Documentation](../ptcmss-backend/README.md)
