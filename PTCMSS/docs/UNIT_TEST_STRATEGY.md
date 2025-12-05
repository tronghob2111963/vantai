# Chiến Lược Viết Unit Test - PTCMSS

## 📊 Tổng Quan

### Mục tiêu
- **Backend**: Đạt 80%+ coverage cho critical services, 70%+ cho supporting services
- **Frontend**: Đạt 70%+ coverage cho critical components, 60%+ cho UI components
- **Mục đích**: Đảm bảo chất lượng code, dễ dàng refactor, phát hiện bug sớm

### Nguyên tắc
1. **Test độc lập**: Mỗi test không phụ thuộc vào test khác
2. **Test nhanh**: Unit test phải chạy nhanh (< 1s/test)
3. **Test rõ ràng**: Tên test mô tả rõ ràng điều gì đang được test
4. **Test cả success và failure**: Test cả trường hợp thành công và thất bại
5. **Test edge cases**: Test các trường hợp biên (null, empty, boundary values)

---

## 🔴 BACKEND - Chiến Lược Unit Test

### Framework & Tools
- **JUnit 5**: Testing framework
- **Mockito**: Mocking dependencies
- **AssertJ**: Fluent assertions
- **JaCoCo**: Code coverage

### Cấu trúc Test

```
src/test/java/org/example/ptcmssbackend/
├── service/
│   ├── ExpenseRequestServiceImplTest.java      [PRIORITY 1]
│   ├── InvoiceServiceImplTest.java             [PRIORITY 2]
│   ├── PaymentServiceImplTest.java             [PRIORITY 2]
│   ├── IncidentServiceTest.java                [PRIORITY 3]
│   ├── EmployeeServiceImplTest.java            [PRIORITY 4]
│   ├── CustomerServiceImplTest.java            [PRIORITY 4]
│   ├── AuthenticationServiceImplTest.java       [PRIORITY 4]
│   ├── NotificationServiceImplTest.java        [PRIORITY 5]
│   ├── SystemSettingServiceImplTest.java       [PRIORITY 5]
│   ├── AnalyticsServiceTest.java               [PRIORITY 5]
│   ├── DepositServiceImplTest.java             [PRIORITY 6]
│   └── RatingServiceImplTest.java              [PRIORITY 6]
├── controller/
│   ├── ExpenseRequestControllerTest.java       [PRIORITY 3]
│   ├── IncidentControllerTest.java             [PRIORITY 3]
│   └── InvoiceControllerTest.java              [PRIORITY 3]
└── repository/
    └── (Custom query tests only)
```

### Template Test Class

```java
package org.example.ptcmssbackend.service;

import org.example.ptcmssbackend.service.impl.ExpenseRequestServiceImpl;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
@DisplayName("ExpenseRequestService Tests")
class ExpenseRequestServiceImplTest {

    @Mock
    private ExpenseRequestRepository expenseRequestRepository;
    @Mock
    private BranchesRepository branchesRepository;
    @Mock
    private VehicleRepository vehicleRepository;
    // ... other mocks

    @InjectMocks
    private ExpenseRequestServiceImpl expenseRequestService;

    @BeforeEach
    void setUp() {
        // Setup common test data
    }

    @Test
    @DisplayName("Should create expense request successfully")
    void createExpenseRequest_WhenValidRequest_ShouldReturnResponse() {
        // Given
        // When
        // Then
    }

    @Test
    @DisplayName("Should throw exception when branch not found")
    void createExpenseRequest_WhenBranchNotFound_ShouldThrowException() {
        // Given
        // When & Then
    }
}
```

### Test Cases Pattern

#### 1. **ExpenseRequestServiceImpl** (Priority 1)

**Method: `createExpenseRequest()`**
- ✅ Tạo request thành công với đầy đủ thông tin
- ✅ Tạo request không có vehicle (vehicleId = null)
- ✅ Tạo request không có requester (requesterUserId = null)
- ❌ Throw exception khi branch không tồn tại
- ❌ Throw exception khi vehicle không tồn tại (nếu vehicleId != null)
- ✅ Gửi notification cho accountants sau khi tạo
- ✅ Set status = PENDING mặc định

**Method: `approveRequest()`**
- ✅ Duyệt request thành công
- ✅ Update notification status khi duyệt
- ✅ Tạo approval history record
- ❌ Throw exception khi request không tồn tại
- ❌ Throw exception khi request không ở trạng thái PENDING
- ✅ Gửi notification cho requester sau khi duyệt

**Method: `rejectRequest()`**
- ✅ Từ chối request thành công
- ✅ Update notification status khi từ chối
- ✅ Lưu rejection reason
- ❌ Throw exception khi request không tồn tại
- ❌ Throw exception khi request không ở trạng thái PENDING

**Method: `listByRequester()`**
- ✅ Trả về danh sách requests của requester
- ✅ Filter theo status nếu có
- ✅ Trả về empty list khi không có requests

#### 2. **InvoiceServiceImpl** (Priority 2)

**Method: `createInvoice()`**
- ✅ Tạo invoice thành công
- ✅ Tính toán VAT đúng
- ✅ Set invoice number tự động
- ❌ Throw exception khi booking không tồn tại
- ✅ Tạo invoice cho deposit và final payment

**Method: `updateInvoice()`**
- ✅ Cập nhật invoice thành công
- ❌ Throw exception khi invoice không tồn tại
- ❌ Throw exception khi invoice đã được thanh toán

**Method: `cancelInvoice()`**
- ✅ Hủy invoice thành công
- ✅ Set cancellation reason
- ❌ Throw exception khi invoice không tồn tại
- ❌ Throw exception khi invoice đã được thanh toán

#### 3. **PaymentServiceImpl** (Priority 2)

**Method: `recordPayment()`**
- ✅ Ghi nhận thanh toán thành công
- ✅ Update invoice payment status
- ✅ Tạo payment history record
- ❌ Throw exception khi invoice không tồn tại
- ❌ Throw exception khi số tiền > số tiền còn lại

**Method: `confirmPayment()`**
- ✅ Xác nhận thanh toán thành công
- ✅ Update payment confirmation status
- ❌ Throw exception khi payment không tồn tại

### Best Practices Backend

1. **Naming Convention**:
   ```java
   methodName_WhenCondition_ShouldExpectedResult()
   ```

2. **AAA Pattern** (Arrange-Act-Assert):
   ```java
   @Test
   void createExpenseRequest_WhenValidRequest_ShouldReturnResponse() {
       // Arrange (Given)
       CreateExpenseRequest request = new CreateExpenseRequest();
       when(branchesRepository.findById(1)).thenReturn(Optional.of(branch));
       
       // Act (When)
       ExpenseRequestResponse response = expenseRequestService.createExpenseRequest(request);
       
       // Assert (Then)
       assertThat(response).isNotNull();
       assertThat(response.getStatus()).isEqualTo(ExpenseRequestStatus.PENDING);
       verify(expenseRequestRepository).save(any(ExpenseRequests.class));
   }
   ```

3. **Mock Verification**:
   - Verify interactions: `verify(repository).save(any())`
   - Verify no interactions: `verify(repository, never()).delete(any())`
   - Verify times: `verify(repository, times(2)).findById(any())`

4. **Exception Testing**:
   ```java
   assertThatThrownBy(() -> service.method())
       .isInstanceOf(RuntimeException.class)
       .hasMessageContaining("Không tìm thấy");
   ```

---

## 🟢 FRONTEND - Chiến Lược Unit Test

### Framework & Tools Setup

**Cần cài đặt:**
```json
{
  "devDependencies": {
    "vitest": "^1.0.0",
    "@testing-library/react": "^14.0.0",
    "@testing-library/jest-dom": "^6.0.0",
    "@testing-library/user-event": "^14.0.0",
    "@vitejs/plugin-react": "^5.0.0",
    "jsdom": "^23.0.0"
  }
}
```

**Setup vitest.config.js:**
```javascript
import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  test: {
    environment: 'jsdom',
    setupFiles: ['./src/test/setup.js'],
    globals: true,
  },
});
```

### Cấu trúc Test

```
src/
├── components/
│   ├── module 2/
│   │   ├── DriverProfilePage.jsx
│   │   └── DriverProfilePage.test.jsx
│   └── common/
│       ├── UserAvatar.jsx
│       └── UserAvatar.test.jsx
├── api/
│   ├── drivers.js
│   └── drivers.test.js
└── test/
    ├── setup.js
    └── mocks/
        ├── api.js
        └── websocket.js
```

### Template Test Component

```javascript
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import DriverProfilePage from './DriverProfilePage';
import * as driversApi from '../../api/drivers';

// Mock API
vi.mock('../../api/drivers', () => ({
  getDriverProfileByUser: vi.fn(),
  updateDriverProfile: vi.fn(),
  uploadDriverAvatar: vi.fn(),
}));

describe('DriverProfilePage', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('should display driver profile when loaded', async () => {
    // Given
    const mockProfile = {
      driverId: 1,
      fullName: 'Tài xế DN D',
      email: 'driver.dn.d@ptcmss.com',
      phone: '0912345104',
    };
    driversApi.getDriverProfileByUser.mockResolvedValue(mockProfile);

    // When
    render(<DriverProfilePage />);

    // Then
    await waitFor(() => {
      expect(screen.getByText('Tài xế DN D')).toBeInTheDocument();
      expect(screen.getByDisplayValue('0912345104')).toBeInTheDocument();
    });
  });

  it('should update profile when save button clicked', async () => {
    // Given
    // When
    // Then
  });
});
```

### Test Cases Pattern Frontend

#### 1. **DriverProfilePage** (Priority 1)

**Component Rendering:**
- ✅ Hiển thị loading state khi đang tải
- ✅ Hiển thị profile data khi load thành công
- ✅ Hiển thị error message khi load thất bại
- ✅ Hiển thị avatar nếu có
- ✅ Hiển thị initials nếu không có avatar

**User Interactions:**
- ✅ Cập nhật phone number khi user nhập
- ✅ Cập nhật address khi user nhập
- ✅ Validate phone number format
- ✅ Validate address length (min 10 characters)
- ✅ Disable save button khi form invalid
- ✅ Enable save button khi có thay đổi

**Avatar Upload:**
- ✅ Hiển thị preview khi chọn ảnh
- ✅ Upload avatar khi click save
- ✅ Hiển thị error khi upload thất bại
- ✅ Validate file type (chỉ image)
- ✅ Validate file size (max 5MB)

**API Integration:**
- ✅ Gọi getDriverProfileByUser khi component mount
- ✅ Gọi updateDriverProfile khi save
- ✅ Gọi uploadDriverAvatar khi có avatar file
- ✅ Handle API errors gracefully

#### 2. **UserAvatar Component**

- ✅ Hiển thị ảnh khi có avatar URL
- ✅ Hiển thị initials khi không có avatar
- ✅ Fallback sang initials khi ảnh load lỗi
- ✅ Apply size correctly
- ✅ Apply className correctly

#### 3. **API Functions**

```javascript
// drivers.test.js
import { describe, it, expect, vi } from 'vitest';
import { getDriverProfileByUser, updateDriverProfile } from './drivers';
import { apiFetch } from './http';

vi.mock('./http');

describe('drivers API', () => {
  it('should call getDriverProfileByUser with correct URL', async () => {
    const mockResponse = { driverId: 1, fullName: 'Test' };
    apiFetch.mockResolvedValue(mockResponse);

    const result = await getDriverProfileByUser(1);

    expect(apiFetch).toHaveBeenCalledWith('/api/drivers/by-user/1/profile');
    expect(result).toEqual(mockResponse);
  });
});
```

### Best Practices Frontend

1. **Mock API calls**:
   ```javascript
   vi.mock('../../api/drivers', () => ({
     getDriverProfileByUser: vi.fn(),
   }));
   ```

2. **Test user interactions**:
   ```javascript
   import userEvent from '@testing-library/user-event';
   
   const user = userEvent.setup();
   await user.type(input, '0912345104');
   ```

3. **Test async operations**:
   ```javascript
   await waitFor(() => {
     expect(screen.getByText('Success')).toBeInTheDocument();
   });
   ```

4. **Test error states**:
   ```javascript
   driversApi.getDriverProfileByUser.mockRejectedValue(new Error('Failed'));
   render(<DriverProfilePage />);
   await waitFor(() => {
     expect(screen.getByText(/error/i)).toBeInTheDocument();
   });
   ```

---

## 📅 Lộ Trình Thực Hiện

### Phase 1: Backend Critical Services (Tuần 1-2)
1. ✅ ExpenseRequestServiceImplTest
2. ✅ InvoiceServiceImplTest
3. ✅ PaymentServiceImplTest

### Phase 2: Backend Controllers & Services (Tuần 3-4)
4. ✅ IncidentControllerTest
5. ✅ EmployeeServiceImplTest
6. ✅ CustomerServiceImplTest

### Phase 3: Frontend Critical Components (Tuần 5-6)
7. ✅ DriverProfilePage.test.jsx
8. ✅ CreateOrderPage.test.jsx
9. ✅ CoordinatorExpenseManagementPage.test.jsx

### Phase 4: Supporting Services & Components (Tuần 7-8)
10. ✅ NotificationServiceImplTest
11. ✅ SystemSettingServiceImplTest
12. ✅ Common components tests

---

## 🎯 Coverage Goals

| Component Type | Target Coverage | Current |
|---------------|----------------|---------|
| Backend Critical Services | 80%+ | ~40% |
| Backend Supporting Services | 70%+ | ~20% |
| Frontend Critical Components | 70%+ | 0% |
| Frontend UI Components | 60%+ | 0% |

---

## 🚀 Chạy Tests

### Backend
```bash
# Tất cả tests
mvn test

# Specific test class
mvn test -Dtest=ExpenseRequestServiceImplTest

# Với coverage
mvn test jacoco:report
# Xem report: target/site/jacoco/index.html
```

### Frontend
```bash
# Tất cả tests
npm run test

# Watch mode
npm run test:watch

# Với coverage
npm run test:coverage
```

---

## 📝 Checklist Trước Khi Commit

- [ ] Tất cả tests pass
- [ ] Coverage đạt mục tiêu
- [ ] Không có test bị skip
- [ ] Test names rõ ràng, mô tả đúng behavior
- [ ] Mock được cleanup sau mỗi test
- [ ] Không có hardcoded values không cần thiết

---

## 🔗 Tài Liệu Tham Khảo

- [JUnit 5 User Guide](https://junit.org/junit5/docs/current/user-guide/)
- [Mockito Documentation](https://javadoc.io/doc/org.mockito/mockito-core/latest/org/mockito/Mockito.html)
- [AssertJ Documentation](https://assertj.github.io/doc/)
- [React Testing Library](https://testing-library.com/docs/react-testing-library/intro/)
- [Vitest Documentation](https://vitest.dev/)

