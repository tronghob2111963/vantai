# 🧩 Module 6: Quản Lý Chi Phí & Tài Chính - Chiến Lược Implementation

**Ngày tạo**: 2025-11-22  
**Trạng thái**: Planning Phase

---

## 📊 Phân Tích Hiện Trạng

### **✅ Entities Đã Có:**

1. ✅ `Invoices` - Hóa đơn (Income/Expense)
2. ✅ `AccountsReceivable` - Công nợ phải thu
3. ✅ `ExpenseRequests` - Yêu cầu chi phí
4. ✅ `Bookings` - Đặt xe (có depositAmount, totalCost)
5. ✅ `Customers` - Khách hàng

### **✅ Services Đã Có:**

1. ✅ `PaymentService` - Xử lý thanh toán
2. ✅ `ExpenseRequestService` - Quản lý yêu cầu chi phí
3. ✅ `InvoiceRepository` - Repository cho invoices

### **⚠️ Cần Bổ Sung:**

1. ❌ `InvoiceService` - Service quản lý hóa đơn
2. ❌ `AccountingService` - Service dashboard & báo cáo
3. ❌ `DepositService` - Service quản lý cọc
4. ❌ `DebtService` - Service quản lý công nợ
5. ❌ Fields mới trong `Invoices` entity
6. ❌ DTOs cho Module 6
7. ❌ Controllers cho Module 6

---

## 🎯 Chiến Lược Implementation

### **Phase 1: Database Schema Updates** ⚡

#### **1.1. Cập Nhật `invoices` Table**

Cần thêm các fields sau:

```sql
ALTER TABLE invoices
ADD COLUMN invoiceNumber VARCHAR(50) UNIQUE COMMENT 'Số HĐ: INV-YYYY-{seq}',
ADD COLUMN dueDate DATE COMMENT 'Hạn thanh toán',
ADD COLUMN paymentTerms VARCHAR(20) DEFAULT 'NET_7' COMMENT 'Điều khoản: NET_7/14/30',
ADD COLUMN vatAmount DECIMAL(18,2) DEFAULT 0 COMMENT 'Tiền thuế VAT',
ADD COLUMN subtotal DECIMAL(18,2) COMMENT 'Tổng trước thuế',
ADD COLUMN bankName VARCHAR(100) COMMENT 'Tên ngân hàng (cho chuyển khoản)',
ADD COLUMN bankAccount VARCHAR(50) COMMENT 'Số tài khoản (cho chuyển khoản)',
ADD COLUMN referenceNumber VARCHAR(50) COMMENT 'Mã tham chiếu (cho chuyển khoản)',
ADD COLUMN cashierName VARCHAR(100) COMMENT 'Người nhận (cho tiền mặt)',
ADD COLUMN receiptNumber VARCHAR(50) COMMENT 'Số phiếu thu',
ADD COLUMN cancelledAt DATETIME NULL COMMENT 'Thời điểm hủy',
ADD COLUMN cancelledBy INT NULL COMMENT 'Người hủy',
ADD COLUMN cancellationReason VARCHAR(500) COMMENT 'Lý do hủy',
ADD COLUMN sentAt DATETIME NULL COMMENT 'Thời điểm gửi HĐ',
ADD COLUMN sentToEmail VARCHAR(100) COMMENT 'Email gửi HĐ',
ADD COLUMN promiseToPayDate DATE NULL COMMENT 'Hẹn thanh toán (cho debt management)',
ADD COLUMN debtLabel VARCHAR(50) NULL COMMENT 'Nhãn nợ: VIP/TRANH_CHAP/NORMAL',
ADD COLUMN contactNote TEXT COMMENT 'Ghi chú liên hệ (cho debt management)';

-- Indexes
CREATE INDEX IX_Invoices_InvoiceNumber ON invoices(invoiceNumber);
CREATE INDEX IX_Invoices_DueDate ON invoices(dueDate);
CREATE INDEX IX_Invoices_Overdue ON invoices(dueDate, paymentStatus) WHERE paymentStatus = 'UNPAID';
```

#### **1.2. Tạo Bảng `payment_history` (Lịch Sử Thanh Toán)**

```sql
CREATE TABLE payment_history (
  paymentId INT AUTO_INCREMENT PRIMARY KEY,
  invoiceId INT NOT NULL,
  paymentDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  amount DECIMAL(18,2) NOT NULL,
  paymentMethod ENUM('CASH','BANK_TRANSFER','QR','CREDIT_CARD') NOT NULL,
  bankName VARCHAR(100),
  bankAccount VARCHAR(50),
  referenceNumber VARCHAR(50),
  cashierName VARCHAR(100),
  receiptNumber VARCHAR(50),
  note VARCHAR(500),
  createdBy INT,
  createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_ph_invoice FOREIGN KEY (invoiceId) REFERENCES invoices(invoiceId),
  CONSTRAINT fk_ph_createdBy FOREIGN KEY (createdBy) REFERENCES employees(employeeId)
) ENGINE=InnoDB;

CREATE INDEX IX_PaymentHistory_Invoice ON payment_history(invoiceId);
CREATE INDEX IX_PaymentHistory_Date ON payment_history(paymentDate);
```

#### **1.3. Tạo Bảng `debt_reminder_history` (Lịch Sử Nhắc Nợ)**

```sql
CREATE TABLE debt_reminder_history (
  reminderId INT AUTO_INCREMENT PRIMARY KEY,
  invoiceId INT NOT NULL,
  reminderDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  reminderType ENUM('EMAIL','SMS','PHONE') NOT NULL,
  recipient VARCHAR(100),
  message TEXT,
  sentBy INT,
  createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_drh_invoice FOREIGN KEY (invoiceId) REFERENCES invoices(invoiceId),
  CONSTRAINT fk_drh_sentBy FOREIGN KEY (sentBy) REFERENCES users(userId)
) ENGINE=InnoDB;

CREATE INDEX IX_DebtReminder_Invoice ON debt_reminder_history(invoiceId);
CREATE INDEX IX_DebtReminder_Date ON debt_reminder_history(reminderDate);
```

---

### **Phase 2: Entity Updates** 📝

#### **2.1. Cập Nhật `Invoices` Entity**

Thêm các fields mới vào `Invoices.java`:

```java
// Invoice number
@Column(name = "invoiceNumber", unique = true, length = 50)
private String invoiceNumber;

// Payment terms
@Column(name = "dueDate")
private LocalDate dueDate;

@Column(name = "paymentTerms", length = 20)
private String paymentTerms = "NET_7"; // NET_7, NET_14, NET_30

// VAT & Subtotal
@Column(name = "vatAmount", precision = 18, scale = 2)
private BigDecimal vatAmount = BigDecimal.ZERO;

@Column(name = "subtotal", precision = 18, scale = 2)
private BigDecimal subtotal;

// Bank transfer info
@Column(name = "bankName", length = 100)
private String bankName;

@Column(name = "bankAccount", length = 50)
private String bankAccount;

@Column(name = "referenceNumber", length = 50)
private String referenceNumber;

// Cash info
@Column(name = "cashierName", length = 100)
private String cashierName;

@Column(name = "receiptNumber", length = 50)
private String receiptNumber;

// Cancellation
@Column(name = "cancelledAt")
private Instant cancelledAt;

@ManyToOne(fetch = FetchType.LAZY)
@JoinColumn(name = "cancelledBy")
private Employees cancelledBy;

@Column(name = "cancellationReason", length = 500)
private String cancellationReason;

// Sending
@Column(name = "sentAt")
private Instant sentAt;

@Column(name = "sentToEmail", length = 100)
private String sentToEmail;

// Debt management
@Column(name = "promiseToPayDate")
private LocalDate promiseToPayDate;

@Column(name = "debtLabel", length = 50)
private String debtLabel; // VIP, TRANH_CHAP, NORMAL

@Column(name = "contactNote", columnDefinition = "TEXT")
private String contactNote;
```

#### **2.2. Tạo Entity `PaymentHistory`**

```java
@Entity
@Table(name = "payment_history")
public class PaymentHistory {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "paymentId")
    private Integer id;
    
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "invoiceId", nullable = false)
    private Invoices invoice;
    
    @Column(name = "paymentDate", nullable = false)
    private Instant paymentDate;
    
    @Column(name = "amount", nullable = false, precision = 18, scale = 2)
    private BigDecimal amount;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "paymentMethod", nullable = false)
    private PaymentMethod paymentMethod;
    
    // Bank transfer fields
    @Column(name = "bankName", length = 100)
    private String bankName;
    
    @Column(name = "bankAccount", length = 50)
    private String bankAccount;
    
    @Column(name = "referenceNumber", length = 50)
    private String referenceNumber;
    
    // Cash fields
    @Column(name = "cashierName", length = 100)
    private String cashierName;
    
    @Column(name = "receiptNumber", length = 50)
    private String receiptNumber;
    
    @Column(name = "note", length = 500)
    private String note;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "createdBy")
    private Employees createdBy;
    
    @CreationTimestamp
    @Column(name = "createdAt")
    private Instant createdAt;
}
```

#### **2.3. Tạo Entity `DebtReminderHistory`**

```java
@Entity
@Table(name = "debt_reminder_history")
public class DebtReminderHistory {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "reminderId")
    private Integer id;
    
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "invoiceId", nullable = false)
    private Invoices invoice;
    
    @Column(name = "reminderDate", nullable = false)
    private Instant reminderDate;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "reminderType", nullable = false)
    private ReminderType reminderType; // EMAIL, SMS, PHONE
    
    @Column(name = "recipient", length = 100)
    private String recipient;
    
    @Column(name = "message", columnDefinition = "TEXT")
    private String message;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "sentBy")
    private Users sentBy;
    
    @CreationTimestamp
    @Column(name = "createdAt")
    private Instant createdAt;
}
```

---

### **Phase 3: Enums & DTOs** 📦

#### **3.1. Enums Mới**

```java
// PaymentMethod.java
public enum PaymentMethod {
    CASH,           // Tiền mặt
    BANK_TRANSFER,  // Chuyển khoản
    QR,             // QR code
    CREDIT_CARD     // Thẻ tín dụng
}

// PaymentTerms.java
public enum PaymentTerms {
    NET_7,   // Thanh toán trong 7 ngày
    NET_14,  // Thanh toán trong 14 ngày
    NET_30,  // Thanh toán trong 30 ngày
    NET_60   // Thanh toán trong 60 ngày
}

// ReminderType.java
public enum ReminderType {
    EMAIL,
    SMS,
    PHONE
}

// DebtLabel.java
public enum DebtLabel {
    NORMAL,      // Bình thường
    VIP,         // Khách VIP
    TRANH_CHAP   // Tranh chấp
}
```

#### **3.2. DTOs Cần Tạo**

**Request DTOs:**
- `CreateInvoiceRequest.java` - Tạo hóa đơn
- `UpdateInvoiceRequest.java` - Cập nhật hóa đơn
- `RecordPaymentRequest.java` - Ghi nhận thanh toán
- `CreateDepositRequest.java` - Tạo cọc
- `SendInvoiceRequest.java` - Gửi hóa đơn
- `VoidInvoiceRequest.java` - Hủy hóa đơn
- `SendDebtReminderRequest.java` - Gửi nhắc nợ
- `UpdateDebtInfoRequest.java` - Cập nhật thông tin nợ
- `RevenueReportRequest.java` - Báo cáo doanh thu
- `ExpenseReportRequest.java` - Báo cáo chi phí

**Response DTOs:**
- `InvoiceResponse.java` - Chi tiết hóa đơn
- `InvoiceListResponse.java` - Danh sách hóa đơn
- `PaymentHistoryResponse.java` - Lịch sử thanh toán
- `DepositResponse.java` - Thông tin cọc
- `DebtSummaryResponse.java` - Tổng hợp công nợ
- `AgingBucketResponse.java` - Phân loại nợ theo thời gian
- `AccountingDashboardResponse.java` - Dashboard kế toán
- `RevenueReportResponse.java` - Báo cáo doanh thu
- `ExpenseReportResponse.java` - Báo cáo chi phí

---

### **Phase 4: Services** 🔧

#### **4.1. InvoiceService**

```java
public interface InvoiceService {
    // CRUD
    InvoiceResponse createInvoice(CreateInvoiceRequest request);
    InvoiceResponse updateInvoice(Integer invoiceId, UpdateInvoiceRequest request);
    InvoiceResponse getInvoiceById(Integer invoiceId);
    Page<InvoiceListResponse> getInvoices(InvoiceFilterRequest filter, Pageable pageable);
    void voidInvoice(Integer invoiceId, VoidInvoiceRequest request);
    
    // Invoice number generation
    String generateInvoiceNumber(Integer branchId);
    
    // Payment
    PaymentHistoryResponse recordPayment(Integer invoiceId, RecordPaymentRequest request);
    List<PaymentHistoryResponse> getPaymentHistory(Integer invoiceId);
    BigDecimal calculateBalance(Integer invoiceId);
    
    // Sending
    void sendInvoice(Integer invoiceId, SendInvoiceRequest request);
    
    // Status updates
    void markAsPaid(Integer invoiceId);
    void markAsOverdue(Integer invoiceId);
}
```

#### **4.2. DepositService**

```java
public interface DepositService {
    DepositResponse createDeposit(Integer bookingId, CreateDepositRequest request);
    DepositResponse updateDeposit(Integer depositId, UpdateDepositRequest request);
    List<DepositResponse> getDepositsByBooking(Integer bookingId);
    DepositSummaryResponse getDepositSummary(Integer bookingId);
    void cancelDeposit(Integer depositId, String reason);
    void printReceipt(Integer depositId);
}
```

#### **4.3. DebtService**

```java
public interface DebtService {
    // Debt list
    Page<DebtSummaryResponse> getDebts(DebtFilterRequest filter, Pageable pageable);
    
    // Aging analysis
    AgingBucketResponse getAgingBuckets(Integer branchId, LocalDate asOfDate);
    
    // Reminders
    void sendDebtReminder(Integer invoiceId, SendDebtReminderRequest request);
    List<DebtReminderHistoryResponse> getReminderHistory(Integer invoiceId);
    
    // Debt management
    void updateDebtInfo(Integer invoiceId, UpdateDebtInfoRequest request);
    void setPromiseToPay(Integer invoiceId, LocalDate promiseDate);
    void setDebtLabel(Integer invoiceId, DebtLabel label);
}
```

#### **4.4. AccountingService**

```java
public interface AccountingService {
    // Dashboard
    AccountingDashboardResponse getDashboard(Integer branchId, DashboardPeriod period);
    
    // Revenue report
    RevenueReportResponse getRevenueReport(RevenueReportRequest request);
    
    // Expense report
    ExpenseReportResponse getExpenseReport(ExpenseReportRequest request);
    
    // Statistics
    BigDecimal getTotalRevenue(Integer branchId, LocalDate startDate, LocalDate endDate);
    BigDecimal getTotalExpense(Integer branchId, LocalDate startDate, LocalDate endDate);
    BigDecimal getARBalance(Integer branchId);
    BigDecimal getAPBalance(Integer branchId);
    int getInvoicesDueIn7Days(Integer branchId);
    int getOverdueInvoices(Integer branchId);
    BigDecimal getCollectionRate(Integer branchId, LocalDate startDate, LocalDate endDate);
    BigDecimal getExpenseToRevenueRatio(Integer branchId, LocalDate startDate, LocalDate endDate);
}
```

---

### **Phase 5: Controllers** 🎮

#### **5.1. InvoiceController**

```java
@RestController
@RequestMapping("/api/invoices")
public class InvoiceController {
    
    @PostMapping
    public ResponseEntity<InvoiceResponse> createInvoice(@RequestBody CreateInvoiceRequest request);
    
    @GetMapping("/{invoiceId}")
    public ResponseEntity<InvoiceResponse> getInvoice(@PathVariable Integer invoiceId);
    
    @GetMapping
    public ResponseEntity<Page<InvoiceListResponse>> getInvoices(
        @RequestParam(required = false) Integer branchId,
        @RequestParam(required = false) String status,
        @RequestParam(required = false) LocalDate startDate,
        @RequestParam(required = false) LocalDate endDate,
        Pageable pageable
    );
    
    @PutMapping("/{invoiceId}")
    public ResponseEntity<InvoiceResponse> updateInvoice(
        @PathVariable Integer invoiceId,
        @RequestBody UpdateInvoiceRequest request
    );
    
    @PostMapping("/{invoiceId}/void")
    public ResponseEntity<Void> voidInvoice(
        @PathVariable Integer invoiceId,
        @RequestBody VoidInvoiceRequest request
    );
    
    @PostMapping("/{invoiceId}/send")
    public ResponseEntity<Void> sendInvoice(
        @PathVariable Integer invoiceId,
        @RequestBody SendInvoiceRequest request
    );
    
    @PostMapping("/{invoiceId}/payments")
    public ResponseEntity<PaymentHistoryResponse> recordPayment(
        @PathVariable Integer invoiceId,
        @RequestBody RecordPaymentRequest request
    );
    
    @GetMapping("/{invoiceId}/payments")
    public ResponseEntity<List<PaymentHistoryResponse>> getPaymentHistory(
        @PathVariable Integer invoiceId
    );
}
```

#### **5.2. DepositController**

```java
@RestController
@RequestMapping("/api/deposits")
public class DepositController {
    
    @PostMapping("/bookings/{bookingId}")
    public ResponseEntity<DepositResponse> createDeposit(
        @PathVariable Integer bookingId,
        @RequestBody CreateDepositRequest request
    );
    
    @GetMapping("/bookings/{bookingId}")
    public ResponseEntity<List<DepositResponse>> getDepositsByBooking(
        @PathVariable Integer bookingId
    );
    
    @GetMapping("/bookings/{bookingId}/summary")
    public ResponseEntity<DepositSummaryResponse> getDepositSummary(
        @PathVariable Integer bookingId
    );
    
    @PostMapping("/{depositId}/cancel")
    public ResponseEntity<Void> cancelDeposit(
        @PathVariable Integer depositId,
        @RequestBody CancelDepositRequest request
    );
    
    @GetMapping("/{depositId}/receipt")
    public ResponseEntity<Resource> printReceipt(@PathVariable Integer depositId);
}
```

#### **5.3. DebtController**

```java
@RestController
@RequestMapping("/api/debts")
public class DebtController {
    
    @GetMapping
    public ResponseEntity<Page<DebtSummaryResponse>> getDebts(
        @RequestParam(required = false) Integer branchId,
        @RequestParam(required = false) Boolean overdueOnly,
        Pageable pageable
    );
    
    @GetMapping("/aging")
    public ResponseEntity<AgingBucketResponse> getAgingBuckets(
        @RequestParam(required = false) Integer branchId,
        @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate asOfDate
    );
    
    @PostMapping("/{invoiceId}/reminder")
    public ResponseEntity<Void> sendReminder(
        @PathVariable Integer invoiceId,
        @RequestBody SendDebtReminderRequest request
    );
    
    @PutMapping("/{invoiceId}/info")
    public ResponseEntity<Void> updateDebtInfo(
        @PathVariable Integer invoiceId,
        @RequestBody UpdateDebtInfoRequest request
    );
}
```

#### **5.4. AccountingController**

```java
@RestController
@RequestMapping("/api/accounting")
public class AccountingController {
    
    @GetMapping("/dashboard")
    public ResponseEntity<AccountingDashboardResponse> getDashboard(
        @RequestParam(required = false) Integer branchId,
        @RequestParam(required = false) String period // THIS_MONTH, THIS_QUARTER, YTD
    );
    
    @GetMapping("/revenue")
    public ResponseEntity<RevenueReportResponse> getRevenueReport(
        @RequestParam(required = false) Integer branchId,
        @RequestParam(required = false) Integer customerId,
        @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
        @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
        @RequestParam(required = false) String period // TODAY, 7D, 30D, MONTH, QUARTER, YTD
    );
    
    @GetMapping("/expense")
    public ResponseEntity<ExpenseReportResponse> getExpenseReport(
        @RequestParam(required = false) Integer branchId,
        @RequestParam(required = false) Integer vehicleId,
        @RequestParam(required = false) String expenseType,
        @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
        @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate
    );
    
    @GetMapping("/export/revenue")
    public ResponseEntity<Resource> exportRevenueReport(RevenueReportRequest request);
    
    @GetMapping("/export/expense")
    public ResponseEntity<Resource> exportExpenseReport(ExpenseReportRequest request);
}
```

---

### **Phase 6: Business Logic** 💼

#### **6.1. Invoice Number Generation**

```java
@Service
public class InvoiceNumberGenerator {
    
    public String generateInvoiceNumber(Integer branchId, LocalDate date) {
        String year = String.valueOf(date.getYear());
        String branchCode = getBranchCode(branchId); // VD: HN, HCM, DN
        int sequence = getNextSequence(branchId, year);
        return String.format("INV-%s-%s-%04d", branchCode, year, sequence);
    }
    
    private int getNextSequence(Integer branchId, String year) {
        // Query max sequence for branch + year
        // Return max + 1
    }
}
```

#### **6.2. Payment Balance Calculation**

```java
public BigDecimal calculateBalance(Integer invoiceId) {
    Invoices invoice = invoiceRepository.findById(invoiceId).orElseThrow();
    BigDecimal totalPaid = paymentHistoryRepository
        .sumByInvoiceId(invoiceId);
    return invoice.getAmount().subtract(totalPaid);
}
```

#### **6.3. Overdue Detection**

```java
@Scheduled(cron = "0 0 1 * * ?") // Chạy mỗi ngày lúc 1h sáng
public void checkOverdueInvoices() {
    LocalDate today = LocalDate.now();
    List<Invoices> unpaidInvoices = invoiceRepository
        .findByPaymentStatusAndDueDateBefore(
            PaymentStatus.UNPAID, 
            today
        );
    
    unpaidInvoices.forEach(invoice -> {
        invoice.setPaymentStatus(PaymentStatus.OVERDUE);
        invoiceRepository.save(invoice);
    });
}
```

#### **6.4. Aging Bucket Calculation**

```java
public AgingBucketResponse calculateAgingBuckets(Integer branchId, LocalDate asOfDate) {
    List<Invoices> unpaidInvoices = invoiceRepository
        .findUnpaidInvoicesByBranch(branchId);
    
    BigDecimal bucket0_30 = BigDecimal.ZERO;
    BigDecimal bucket31_60 = BigDecimal.ZERO;
    BigDecimal bucket61_90 = BigDecimal.ZERO;
    BigDecimal bucketOver90 = BigDecimal.ZERO;
    
    for (Invoices invoice : unpaidInvoices) {
        long daysOverdue = ChronoUnit.DAYS.between(
            invoice.getDueDate(), 
            asOfDate
        );
        BigDecimal balance = calculateBalance(invoice.getId());
        
        if (daysOverdue <= 30) {
            bucket0_30 = bucket0_30.add(balance);
        } else if (daysOverdue <= 60) {
            bucket31_60 = bucket31_60.add(balance);
        } else if (daysOverdue <= 90) {
            bucket61_90 = bucket61_90.add(balance);
        } else {
            bucketOver90 = bucketOver90.add(balance);
        }
    }
    
    return AgingBucketResponse.builder()
        .bucket0_30(bucket0_30)
        .bucket31_60(bucket31_60)
        .bucket61_90(bucket61_90)
        .bucketOver90(bucketOver90)
        .total(bucket0_30.add(bucket31_60).add(bucket61_90).add(bucketOver90))
        .build();
}
```

---

### **Phase 7: Views & Queries** 📊

#### **7.1. View: `v_accounting_dashboard`**

```sql
CREATE VIEW v_accounting_dashboard AS
SELECT 
    b.branchId,
    DATE(i.invoiceDate) AS date,
    -- Revenue
    SUM(CASE WHEN i.type = 'INCOME' AND i.paymentStatus = 'PAID' 
        THEN i.amount ELSE 0 END) AS revenue,
    -- Expense
    SUM(CASE WHEN i.type = 'EXPENSE' AND i.paymentStatus = 'PAID' 
        THEN i.amount ELSE 0 END) AS expense,
    -- AR Balance
    SUM(CASE WHEN i.type = 'INCOME' AND i.paymentStatus IN ('UNPAID', 'OVERDUE')
        THEN (i.amount - COALESCE(ph.totalPaid, 0)) ELSE 0 END) AS arBalance,
    -- Invoices due in 7 days
    COUNT(CASE WHEN i.type = 'INCOME' 
        AND i.paymentStatus = 'UNPAID'
        AND i.dueDate BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 7 DAY)
        THEN 1 END) AS invoicesDueIn7Days,
    -- Overdue invoices
    COUNT(CASE WHEN i.type = 'INCOME' 
        AND i.paymentStatus = 'OVERDUE'
        THEN 1 END) AS overdueInvoices
FROM invoices i
JOIN branches b ON i.branchId = b.branchId
LEFT JOIN (
    SELECT invoiceId, SUM(amount) AS totalPaid
    FROM payment_history
    GROUP BY invoiceId
) ph ON i.invoiceId = ph.invoiceId
GROUP BY b.branchId, DATE(i.invoiceDate);
```

#### **7.2. View: `v_revenue_report`**

```sql
CREATE VIEW v_revenue_report AS
SELECT 
    i.invoiceId,
    i.invoiceNumber,
    i.invoiceDate,
    i.amount,
    i.paymentStatus,
    i.paymentMethod,
    b.branchId,
    b.branchName,
    c.customerId,
    c.fullName AS customerName,
    bk.bookingId,
    COALESCE(ph.totalPaid, 0) AS paidAmount,
    (i.amount - COALESCE(ph.totalPaid, 0)) AS balance
FROM invoices i
JOIN branches b ON i.branchId = b.branchId
LEFT JOIN customers c ON i.customerId = c.customerId
LEFT JOIN bookings bk ON i.bookingId = bk.bookingId
LEFT JOIN (
    SELECT invoiceId, SUM(amount) AS totalPaid
    FROM payment_history
    GROUP BY invoiceId
) ph ON i.invoiceId = ph.invoiceId
WHERE i.type = 'INCOME';
```

---

## 📋 Implementation Checklist

### **Backend Tasks:**

- [ ] **Database Schema**
  - [ ] Update `invoices` table với fields mới
  - [ ] Create `payment_history` table
  - [ ] Create `debt_reminder_history` table
  - [ ] Create views: `v_accounting_dashboard`, `v_revenue_report`
  - [ ] Create indexes cho performance

- [ ] **Entities**
  - [ ] Update `Invoices` entity
  - [ ] Create `PaymentHistory` entity
  - [ ] Create `DebtReminderHistory` entity

- [ ] **Enums**
  - [ ] Create `PaymentMethod` enum
  - [ ] Create `PaymentTerms` enum
  - [ ] Create `ReminderType` enum
  - [ ] Create `DebtLabel` enum

- [ ] **DTOs**
  - [ ] Create all Request DTOs (10 DTOs)
  - [ ] Create all Response DTOs (9 DTOs)

- [ ] **Repositories**
  - [ ] Update `InvoiceRepository` với queries mới
  - [ ] Create `PaymentHistoryRepository`
  - [ ] Create `DebtReminderHistoryRepository`

- [ ] **Services**
  - [ ] Create `InvoiceService` & `InvoiceServiceImpl`
  - [ ] Create `DepositService` & `DepositServiceImpl`
  - [ ] Create `DebtService` & `DebtServiceImpl`
  - [ ] Create `AccountingService` & `AccountingServiceImpl`

- [ ] **Controllers**
  - [ ] Create `InvoiceController`
  - [ ] Create `DepositController`
  - [ ] Create `DebtController`
  - [ ] Create `AccountingController`

- [ ] **Business Logic**
  - [ ] Invoice number generation
  - [ ] Payment balance calculation
  - [ ] Overdue detection (scheduled job)
  - [ ] Aging bucket calculation
  - [ ] Revenue/Expense aggregation

- [ ] **Export Features**
  - [ ] Excel export service
  - [ ] PDF export service (invoice, receipt)
  - [ ] CSV export service

---

## 🚀 Thứ Tự Implementation

### **Week 1: Foundation**
1. Database schema updates
2. Entity updates & new entities
3. Enums & basic DTOs

### **Week 2: Core Services**
1. InvoiceService (CRUD + payment)
2. DepositService
3. Basic AccountingService

### **Week 3: Advanced Features**
1. DebtService
2. Advanced AccountingService (reports)
3. Export features

### **Week 4: Controllers & Testing**
1. All controllers
2. Integration testing
3. Performance optimization

---

## 📝 Notes

1. **Invoice Number**: Format `INV-{BRANCH}-{YYYY}-{SEQ}` (VD: INV-HN-2025-0001)
2. **Payment Terms**: Mặc định NET_7, có thể config trong system_settings
3. **Overdue Detection**: Scheduled job chạy mỗi ngày
4. **Export**: Dùng Apache POI cho Excel, iText cho PDF
5. **QR Payment**: Tích hợp với payment gateway (có thể thêm sau)

---

**Ngày tạo**: 2025-11-22  
**Trạng thái**: Ready for Implementation

