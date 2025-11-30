# Cập nhật: Kế toán có thể xem chi tiết đơn hàng

## Vấn đề

Trước đây, khi set `showActions={!isManager && !isAccountant}`, cả cột "Hành động" bị ẩn luôn, bao gồm cả nút "Chi tiết". Điều này khiến Kế toán không thể xem chi tiết đơn hàng.

## Giải pháp

Tách riêng logic hiển thị:
- **Nút "Chi tiết"**: Luôn hiển thị cho tất cả role (bao gồm Kế toán)
- **Nút "Sửa"**: Chỉ hiển thị cho Admin, Consultant, Coordinator (ẩn với Manager và Accountant)

## Chi tiết thay đổi

### File: `ConsultantOrderListPage.jsx`

#### 1. Cột "Hành động" luôn hiển thị

**Trước:**
```javascript
{showActions && (
    <th className="px-3 py-2 font-medium text-slate-500 text-[12px]">
        Hành động
    </th>
)}
```

**Sau:**
```javascript
<th className="px-3 py-2 font-medium text-slate-500 text-[12px]">
    Hành động
</th>
```

#### 2. Nút "Chi tiết" luôn hiển thị, nút "Sửa" có điều kiện

**Trước:**
```javascript
{showActions && (
    <td className="px-3 py-2 text-[13px] whitespace-nowrap">
        <div className="flex items-center gap-2 flex-wrap">
            <button onClick={() => onViewDetail(o)}>
                <Eye />
                <span>Chi tiết</span>
            </button>

            <button onClick={() => onEdit(o)}>
                <Pencil />
                <span>Sửa</span>
            </button>
        </div>
    </td>
)}
```

**Sau:**
```javascript
<td className="px-3 py-2 text-[13px] whitespace-nowrap">
    <div className="flex items-center gap-2 flex-wrap">
        {/* Nút Chi tiết - Luôn hiển thị */}
        <button onClick={() => onViewDetail(o)}>
            <Eye />
            <span>Chi tiết</span>
        </button>

        {/* Nút Sửa - Chỉ hiển thị khi showActions=true */}
        {showActions && (
            <button onClick={() => onEdit(o)}>
                <Pencil />
                <span>Sửa</span>
            </button>
        )}
    </div>
</td>
```

#### 3. Sửa colspan trong empty state

**Trước:**
```javascript
<td colSpan={showActions ? 9 : 8}>
    Không có đơn hàng phù hợp.
</td>
```

**Sau:**
```javascript
<td colSpan={9}>
    Không có đơn hàng phù hợp.
</td>
```

## Kết quả

### Kế toán (ACCOUNTANT):
- ✅ Xem danh sách đơn hàng
- ✅ Click nút "Chi tiết" để xem chi tiết đơn hàng
- ✅ Navigate đến `/orders/:orderId` (OrderDetailPage)
- ❌ Không có nút "Sửa"
- ❌ Không thể sửa đơn hàng
- ❌ Không thể tạo thanh toán (đã xóa ở OrderDetailPage)

### Manager (MANAGER):
- ✅ Xem danh sách đơn hàng
- ✅ Click nút "Chi tiết" để xem chi tiết
- ❌ Không có nút "Sửa"

### Admin, Consultant, Coordinator:
- ✅ Xem danh sách đơn hàng
- ✅ Click nút "Chi tiết" để xem chi tiết
- ✅ Click nút "Sửa" để sửa đơn hàng
- ✅ Tạo thanh toán TM/QR

## Flow xem chi tiết đơn hàng

1. Kế toán vào menu "Danh sách đơn hàng" (`/accountant/orders`)
2. Click nút "Chi tiết" trên một đơn hàng
3. Navigate đến `/orders/:orderId` (OrderDetailPage)
4. Xem đầy đủ thông tin:
   - Thông tin khách hàng
   - Lịch trình
   - Báo giá
   - Thông tin thanh toán (đã thu, còn lại)
   - Lịch sử thanh toán
5. **Không thể:**
   - Sửa đơn hàng
   - Tạo thanh toán mới
   - Tạo QR thanh toán

## Testing

### Test Case 1: Kế toán xem chi tiết đơn hàng
1. Đăng nhập với tài khoản Kế toán
2. Vào menu "Danh sách đơn hàng"
3. Kiểm tra:
   - Cột "Hành động" hiển thị
   - Mỗi đơn có nút "Chi tiết"
   - Không có nút "Sửa"
4. Click nút "Chi tiết"
5. Kiểm tra:
   - Navigate đến trang chi tiết đơn hàng
   - Hiển thị đầy đủ thông tin
   - Không có nút "Ghi nhận thanh toán"
   - Không có nút "Tạo QR"

### Test Case 2: Consultant vẫn có đầy đủ quyền
1. Đăng nhập với tài khoản Consultant
2. Vào danh sách đơn hàng
3. Kiểm tra:
   - Có nút "Chi tiết"
   - Có nút "Sửa"
4. Click "Chi tiết" → Xem được chi tiết
5. Click "Sửa" → Có thể sửa đơn hàng
6. Vào chi tiết đơn → Có nút "Ghi nhận thanh toán" và "Tạo QR"

## Files đã thay đổi

1. `vantai/PTCMSS_FRONTEND/src/components/module 4/ConsultantOrderListPage.jsx`
   - Cột "Hành động" luôn hiển thị
   - Nút "Chi tiết" luôn hiển thị
   - Nút "Sửa" chỉ hiển thị khi `showActions=true`
   - Sửa colspan trong empty state

## Lưu ý

- Nút "Chi tiết" navigate đến `/orders/:orderId`, không phải mở modal
- OrderDetailPage đã được cập nhật trước đó để ẩn các nút thanh toán cho tất cả role (không chỉ Accountant)
- Nếu cần thêm logic riêng cho Accountant trong OrderDetailPage, có thể thêm check `isAccountant` tương tự như `isConsultant`
