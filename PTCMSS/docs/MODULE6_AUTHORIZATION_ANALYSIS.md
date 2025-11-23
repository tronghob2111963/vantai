# 🔐 Module 6 Authorization Analysis

## 📋 Phân Tích Quyền Hạn Theo Role

### **Roles trong hệ thống:**
1. **ADMIN** - Quản trị viên hệ thống
2. **MANAGER** - Quản lý chi nhánh
3. **ACCOUNTANT** - Kế toán
4. **CONSULTANT** - Điều hành/Tư vấn
5. **DRIVER** - Tài xế

---

## 🎯 Module 6: Quản Lý Chi Phí & Tài Chính

### **1. Invoice Management** (`/api/invoices`)

#### **Tạo hóa đơn (POST `/api/invoices`)**
- ✅ **ADMIN**: Toàn quyền
- ✅ **MANAGER**: Tạo invoices cho chi nhánh mình
- ✅ **ACCOUNTANT**: Tạo invoices (Income/Expense)
- ❌ **CONSULTANT**: Không có quyền
- ❌ **DRIVER**: Không có quyền

**Authorization**: `@PreAuthorize("hasAnyRole('ADMIN','MANAGER','ACCOUNTANT')")`

#### **Xem hóa đơn (GET `/api/invoices`, GET `/api/invoices/{id}`)**
- ✅ **ADMIN**: Xem tất cả
- ✅ **MANAGER**: Xem invoices của chi nhánh mình
- ✅ **ACCOUNTANT**: Xem tất cả invoices
- ✅ **CONSULTANT**: Xem invoices liên quan đến bookings của mình
- ❌ **DRIVER**: Không có quyền (hoặc chỉ xem expense invoices của mình)

**Authorization**: `@PreAuthorize("hasAnyRole('ADMIN','MANAGER','ACCOUNTANT','CONSULTANT')")`

#### **Cập nhật hóa đơn (PUT `/api/invoices/{id}`)**
- ✅ **ADMIN**: Toàn quyền
- ✅ **MANAGER**: Cập nhật invoices của chi nhánh mình (chưa thanh toán)
- ✅ **ACCOUNTANT**: Cập nhật invoices (chưa thanh toán)
- ❌ **CONSULTANT**: Không có quyền
- ❌ **DRIVER**: Không có quyền

**Authorization**: `@PreAuthorize("hasAnyRole('ADMIN','MANAGER','ACCOUNTANT')")`

#### **Hủy hóa đơn (POST `/api/invoices/{id}/void`)**
- ✅ **ADMIN**: Toàn quyền
- ✅ **MANAGER**: Hủy invoices của chi nhánh mình
- ✅ **ACCOUNTANT**: Hủy invoices
- ❌ **CONSULTANT**: Không có quyền
- ❌ **DRIVER**: Không có quyền

**Authorization**: `@PreAuthorize("hasAnyRole('ADMIN','MANAGER','ACCOUNTANT')")`

#### **Ghi nhận thanh toán (POST `/api/invoices/{id}/payments`)**
- ✅ **ADMIN**: Toàn quyền
- ✅ **MANAGER**: Ghi nhận thanh toán cho chi nhánh mình
- ✅ **ACCOUNTANT**: Ghi nhận thanh toán (chức năng chính)
- ❌ **CONSULTANT**: Không có quyền
- ❌ **DRIVER**: Không có quyền

**Authorization**: `@PreAuthorize("hasAnyRole('ADMIN','MANAGER','ACCOUNTANT')")`

#### **Xem lịch sử thanh toán (GET `/api/invoices/{id}/payments`)**
- ✅ **ADMIN**: Xem tất cả
- ✅ **MANAGER**: Xem của chi nhánh mình
- ✅ **ACCOUNTANT**: Xem tất cả
- ✅ **CONSULTANT**: Xem của bookings mình tạo
- ❌ **DRIVER**: Không có quyền

**Authorization**: `@PreAuthorize("hasAnyRole('ADMIN','MANAGER','ACCOUNTANT','CONSULTANT')")`

#### **Gửi hóa đơn (POST `/api/invoices/{id}/send`)**
- ✅ **ADMIN**: Toàn quyền
- ✅ **MANAGER**: Gửi invoices của chi nhánh mình
- ✅ **ACCOUNTANT**: Gửi invoices (chức năng chính)
- ❌ **CONSULTANT**: Không có quyền
- ❌ **DRIVER**: Không có quyền

**Authorization**: `@PreAuthorize("hasAnyRole('ADMIN','MANAGER','ACCOUNTANT')")`

#### **Đánh dấu đã thanh toán (POST `/api/invoices/{id}/mark-paid`)**
- ✅ **ADMIN**: Toàn quyền
- ✅ **MANAGER**: Cho chi nhánh mình
- ✅ **ACCOUNTANT**: Toàn quyền
- ❌ **CONSULTANT**: Không có quyền
- ❌ **DRIVER**: Không có quyền

**Authorization**: `@PreAuthorize("hasAnyRole('ADMIN','MANAGER','ACCOUNTANT')")`

---

### **2. Deposit Management** (`/api/deposits`)

#### **Tạo cọc (POST `/api/deposits/bookings/{id}`)**
- ✅ **ADMIN**: Toàn quyền
- ✅ **MANAGER**: Tạo cọc cho bookings của chi nhánh mình
- ✅ **ACCOUNTANT**: Tạo cọc
- ✅ **CONSULTANT**: Tạo cọc cho bookings mình tạo
- ❌ **DRIVER**: Không có quyền

**Authorization**: `@PreAuthorize("hasAnyRole('ADMIN','MANAGER','ACCOUNTANT','CONSULTANT')")`

#### **Xem cọc (GET `/api/deposits/bookings/{id}`)**
- ✅ **ADMIN**: Xem tất cả
- ✅ **MANAGER**: Xem của chi nhánh mình
- ✅ **ACCOUNTANT**: Xem tất cả
- ✅ **CONSULTANT**: Xem của bookings mình tạo
- ❌ **DRIVER**: Không có quyền

**Authorization**: `@PreAuthorize("hasAnyRole('ADMIN','MANAGER','ACCOUNTANT','CONSULTANT')")`

#### **Hủy cọc (POST `/api/deposits/{id}/cancel`)**
- ✅ **ADMIN**: Toàn quyền
- ✅ **MANAGER**: Hủy cọc của chi nhánh mình
- ✅ **ACCOUNTANT**: Hủy cọc
- ❌ **CONSULTANT**: Không có quyền
- ❌ **DRIVER**: Không có quyền

**Authorization**: `@PreAuthorize("hasAnyRole('ADMIN','MANAGER','ACCOUNTANT')")`

---

### **3. Debt Management** (`/api/debts`)

#### **Xem danh sách nợ (GET `/api/debts`)**
- ✅ **ADMIN**: Xem tất cả
- ✅ **MANAGER**: Xem nợ của chi nhánh mình
- ✅ **ACCOUNTANT**: Xem tất cả (chức năng chính)
- ❌ **CONSULTANT**: Không có quyền
- ❌ **DRIVER**: Không có quyền

**Authorization**: `@PreAuthorize("hasAnyRole('ADMIN','MANAGER','ACCOUNTANT')")`

#### **Phân tích aging (GET `/api/debts/aging`)**
- ✅ **ADMIN**: Xem tất cả
- ✅ **MANAGER**: Xem của chi nhánh mình
- ✅ **ACCOUNTANT**: Xem tất cả
- ❌ **CONSULTANT**: Không có quyền
- ❌ **DRIVER**: Không có quyền

**Authorization**: `@PreAuthorize("hasAnyRole('ADMIN','MANAGER','ACCOUNTANT')")`

#### **Gửi nhắc nợ (POST `/api/debts/{id}/reminder`)**
- ✅ **ADMIN**: Toàn quyền
- ✅ **MANAGER**: Gửi nhắc nợ cho chi nhánh mình
- ✅ **ACCOUNTANT**: Gửi nhắc nợ (chức năng chính)
- ❌ **CONSULTANT**: Không có quyền
- ❌ **DRIVER**: Không có quyền

**Authorization**: `@PreAuthorize("hasAnyRole('ADMIN','MANAGER','ACCOUNTANT')")`

#### **Cập nhật thông tin nợ (PUT `/api/debts/{id}/info`)**
- ✅ **ADMIN**: Toàn quyền
- ✅ **MANAGER**: Cập nhật nợ của chi nhánh mình
- ✅ **ACCOUNTANT**: Cập nhật nợ (chức năng chính)
- ❌ **CONSULTANT**: Không có quyền
- ❌ **DRIVER**: Không có quyền

**Authorization**: `@PreAuthorize("hasAnyRole('ADMIN','MANAGER','ACCOUNTANT')")`

---

### **4. Accounting & Reports** (`/api/accounting`)

#### **Dashboard (GET `/api/accounting/dashboard`)**
- ✅ **ADMIN**: Xem tất cả
- ✅ **MANAGER**: Xem dashboard của chi nhánh mình
- ✅ **ACCOUNTANT**: Xem tất cả (chức năng chính)
- ❌ **CONSULTANT**: Không có quyền
- ❌ **DRIVER**: Không có quyền

**Authorization**: `@PreAuthorize("hasAnyRole('ADMIN','MANAGER','ACCOUNTANT')")`

#### **Báo cáo doanh thu (GET `/api/accounting/revenue`)**
- ✅ **ADMIN**: Xem tất cả
- ✅ **MANAGER**: Xem của chi nhánh mình
- ✅ **ACCOUNTANT**: Xem tất cả (chức năng chính)
- ❌ **CONSULTANT**: Không có quyền
- ❌ **DRIVER**: Không có quyền

**Authorization**: `@PreAuthorize("hasAnyRole('ADMIN','MANAGER','ACCOUNTANT')")`

#### **Báo cáo chi phí (GET `/api/accounting/expense`)**
- ✅ **ADMIN**: Xem tất cả
- ✅ **MANAGER**: Xem của chi nhánh mình
- ✅ **ACCOUNTANT**: Xem tất cả (chức năng chính)
- ❌ **CONSULTANT**: Không có quyền
- ❌ **DRIVER**: Không có quyền

**Authorization**: `@PreAuthorize("hasAnyRole('ADMIN','MANAGER','ACCOUNTANT')")`

#### **Thống kê (GET `/api/accounting/stats/*`)**
- ✅ **ADMIN**: Xem tất cả
- ✅ **MANAGER**: Xem của chi nhánh mình
- ✅ **ACCOUNTANT**: Xem tất cả
- ❌ **CONSULTANT**: Không có quyền
- ❌ **DRIVER**: Không có quyền

**Authorization**: `@PreAuthorize("hasAnyRole('ADMIN','MANAGER','ACCOUNTANT')")`

---

### **5. Export Services** (`/api/export`)

#### **Export Reports (GET `/api/export/*`)**
- ✅ **ADMIN**: Export tất cả
- ✅ **MANAGER**: Export reports của chi nhánh mình
- ✅ **ACCOUNTANT**: Export tất cả (chức năng chính)
- ❌ **CONSULTANT**: Không có quyền
- ❌ **DRIVER**: Không có quyền

**Authorization**: `@PreAuthorize("hasAnyRole('ADMIN','MANAGER','ACCOUNTANT')")`

---

## 📊 Tóm Tắt Quyền Hạn

| Role | Invoice | Deposit | Debt | Accounting | Export |
|------|---------|---------|------|------------|--------|
| **ADMIN** | ✅ Toàn quyền | ✅ Toàn quyền | ✅ Toàn quyền | ✅ Toàn quyền | ✅ Toàn quyền |
| **MANAGER** | ✅ Chi nhánh | ✅ Chi nhánh | ✅ Chi nhánh | ✅ Chi nhánh | ✅ Chi nhánh |
| **ACCOUNTANT** | ✅ Toàn quyền | ✅ Toàn quyền | ✅ Toàn quyền | ✅ Toàn quyền | ✅ Toàn quyền |
| **CONSULTANT** | 👁️ Xem (bookings của mình) | ✅ Tạo/Xem (bookings của mình) | ❌ Không có quyền | ❌ Không có quyền | ❌ Không có quyền |
| **DRIVER** | ❌ Không có quyền | ❌ Không có quyền | ❌ Không có quyền | ❌ Không có quyền | ❌ Không có quyền |

---

## 🔐 Implementation

Tất cả endpoints cần thêm `@PreAuthorize` với quyền hạn phù hợp như phân tích trên.

