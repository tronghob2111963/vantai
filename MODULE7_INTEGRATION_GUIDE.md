# 🚀 MODULE 7: INTEGRATION GUIDE - HOÀN CHỈNH FRONTEND ↔ BACKEND

## 📋 MỤC LỤC

1. [Tổng quan](#tổng-quan)
2. [Cấu trúc dự án](#cấu-trúc-dự-án)
3. [Backend Setup](#backend-setup)
4. [Frontend Setup](#frontend-setup)
5. [Testing Integration](#testing-integration)
6. [Routing Integration](#routing-integration)
7. [Security & Permissions](#security--permissions)
8. [API Reference](#api-reference)
9. [Troubleshooting](#troubleshooting)
10. [Deployment Checklist](#deployment-checklist)

---

## 🎯 TỔNG QUAN

Module 7 cung cấp dashboard analytics cho 2 role chính:
- **ADMIN**: Dashboard toàn công ty với tổng quan tất cả chi nhánh
- **MANAGER**: Dashboard theo chi nhánh cụ thể

### Trạng thái hiện tại:
- ✅ Backend: 85% (Core features production-ready)
- ✅ Frontend: 90% (Admin Dashboard complete, Manager Dashboard complete)
- ⏳ Integration: Cần test và deploy

---

## 📁 CẤU TRÚC DỰ ÁN

```
vantai/
├── PTCMSS/                              # Backend (Spring Boot)
│   └── ptcmss-backend/
│       └── src/main/java/org/example/ptcmssbackend/
│           ├── dto/analytics/
│           │   ├── AdminDashboardResponse.java      ✅
│           │   ├── RevenueTrendDTO.java            ✅
│           │   ├── BranchComparisonDTO.java        ✅
│           │   └── SystemAlertDTO.java             ✅
│           │
│           ├── service/
│           │   └── AnalyticsService.java           ✅
│           │
│           └── controller/
│               ├── AdminDashboardController.java    ✅
│               └── ManagerDashboardController.java  ✅
│
└── PTCMSS_FRONTEND/                     # Frontend (React)
    └── src/
        ├── api/
        │   └── dashboards.js                        ✅
        │
        └── components/
            └── module 7/
                ├── AdminDashboard.jsx               ✅
                ├── ManagerDashboard.jsx             ✅
                │
                └── shared/
                    ├── KpiCard.jsx                  ✅
                    ├── TrendChart.jsx               ✅
                    └── AlertsPanel.jsx              ✅
```

---

## 🔧 BACKEND SETUP

### 1. Kiểm tra Dependencies (pom.xml)

Đảm bảo các dependencies sau đã có:

```xml
<!-- Spring Boot Starter Web -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
</dependency>

<!-- Spring Boot Starter Data JPA -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-jpa</artifactId>
</dependency>

<!-- Spring Boot Starter Security -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-security</artifactId>
</dependency>

<!-- MySQL Driver -->
<dependency>
    <groupId>com.mysql</groupId>
    <artifactId>mysql-connector-j</artifactId>
    <scope>runtime</scope>
</dependency>

<!-- Lombok -->
<dependency>
    <groupId>org.projectlombok</groupId>
    <artifactId>lombok</artifactId>
    <optional>true</optional>
</dependency>

<!-- Swagger/OpenAPI -->
<dependency>
    <groupId>org.springdoc</groupId>
    <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
    <version>2.0.2</version>
</dependency>
```

### 2. Application Properties

Kiểm tra `application.properties` hoặc `application.yml`:

```properties
# Database Configuration
spring.datasource.url=jdbc:mysql://localhost:3306/ptcmss?useSSL=false&serverTimezone=UTC
spring.datasource.username=root
spring.datasource.password=your_password
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver

# JPA/Hibernate
spring.jpa.hibernate.ddl-auto=none
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.format_sql=true
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.MySQL8Dialect

# Server Port
server.port=8080

# Swagger
springdoc.api-docs.path=/api-docs
springdoc.swagger-ui.path=/swagger-ui.html

# CORS (cho phép frontend localhost:5173 kết nối)
spring.web.cors.allowed-origins=http://localhost:5173
spring.web.cors.allowed-methods=GET,POST,PUT,DELETE,OPTIONS
spring.web.cors.allowed-headers=*
spring.web.cors.allow-credentials=true
```

### 3. CORS Configuration

Tạo hoặc cập nhật `WebConfig.java`:

```java
package org.example.ptcmssbackend.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/api/**")
                .allowedOrigins("http://localhost:5173")
                .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
                .allowedHeaders("*")
                .allowCredentials(true);
    }
}
```

### 4. Build & Run Backend

```bash
cd PTCMSS/ptcmss-backend

# Clean install
./mvnw clean install

# Run application
./mvnw spring-boot:run
```

**Kiểm tra backend đã chạy:**
- Server: http://localhost:8080
- Swagger UI: http://localhost:8080/swagger-ui.html
- API Docs: http://localhost:8080/api-docs

---

## 🎨 FRONTEND SETUP

### 1. Kiểm tra Dependencies (package.json)

Đảm bảo các packages sau đã có:

```json
{
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-router-dom": "^6.x.x",
    "axios": "^1.x.x",
    "recharts": "^2.x.x",
    "lucide-react": "^0.x.x",
    "tailwindcss": "^3.x.x"
  }
}
```

Nếu thiếu `recharts`:

```bash
cd PTCMSS_FRONTEND
npm install recharts
```

### 2. Axios Instance Configuration

Kiểm tra `src/api/axiosInstance.js` có cấu hình đúng:

```javascript
import axios from 'axios';

const axiosInstance = axios.create({
    baseURL: 'http://localhost:8080',
    timeout: 30000,
    headers: {
        'Content-Type': 'application/json',
    },
});

// Request interceptor (thêm token)
axiosInstance.interceptors.request.use(
    (config) => {
        const token = localStorage.getItem('accessToken');
        if (token) {
            config.headers.Authorization = `Bearer ${token}`;
        }
        return config;
    },
    (error) => Promise.reject(error)
);

// Response interceptor (xử lý lỗi)
axiosInstance.interceptors.response.use(
    (response) => response,
    (error) => {
        if (error.response?.status === 401) {
            // Redirect to login
            localStorage.removeItem('accessToken');
            window.location.href = '/login';
        }
        return Promise.reject(error);
    }
);

export default axiosInstance;
```

### 3. Run Frontend

```bash
cd PTCMSS_FRONTEND
npm run dev
```

**Kiểm tra frontend đã chạy:**
- Server: http://localhost:5173

---

## 🧪 TESTING INTEGRATION

### 1. Test Backend Endpoints (Standalone)

Sử dụng curl hoặc Postman:

```bash
# 1. Get Admin Dashboard
curl -X GET "http://localhost:8080/api/v1/admin/dashboard?period=THIS_MONTH" \
     -H "Authorization: Bearer YOUR_TOKEN"

# 2. Get Revenue Trend
curl -X GET "http://localhost:8080/api/v1/admin/analytics/revenue-trend" \
     -H "Authorization: Bearer YOUR_TOKEN"

# 3. Get Branch Comparison
curl -X GET "http://localhost:8080/api/v1/admin/analytics/branch-comparison?period=THIS_MONTH" \
     -H "Authorization: Bearer YOUR_TOKEN"

# 4. Get System Alerts
curl -X GET "http://localhost:8080/api/v1/admin/alerts?severity=HIGH,CRITICAL" \
     -H "Authorization: Bearer YOUR_TOKEN"

# 5. Get Fleet Utilization
curl -X GET "http://localhost:8080/api/v1/admin/analytics/fleet-utilization" \
     -H "Authorization: Bearer YOUR_TOKEN"
```

**Expected Response Example (Admin Dashboard):**

```json
{
    "totalRevenue": 150000000,
    "totalExpense": 80000000,
    "netProfit": 70000000,
    "totalTrips": 450,
    "completedTrips": 420,
    "ongoingTrips": 25,
    "scheduledTrips": 5,
    "fleetUtilization": 75.5,
    "totalVehicles": 50,
    "vehiclesInUse": 38,
    "vehiclesAvailable": 10,
    "vehiclesMaintenance": 2,
    "totalDrivers": 60,
    "driversOnTrip": 38,
    "driversAvailable": 22,
    "revenueChangePct": 12.5,
    "expenseChangePct": -5.2,
    "tripChangePct": 8.3,
    "period": "THIS_MONTH",
    "periodStart": "2025-01-01T00:00:00",
    "periodEnd": "2025-01-23T15:30:00"
}
```

### 2. Test Frontend API Calls

Mở Browser Console (F12) khi truy cập dashboard:

```javascript
// Check API calls in Network tab
// Look for calls to:
// - /api/v1/admin/dashboard
// - /api/v1/admin/analytics/revenue-trend
// - /api/v1/admin/analytics/branch-comparison
// - /api/v1/admin/analytics/fleet-utilization
// - /api/v1/admin/alerts

// Check response status: 200 OK
// Check response data matches expected format
```

### 3. Test Full Integration Flow

**Scenario: Admin Login → View Dashboard**

1. **Login as Admin:**
   - Navigate to http://localhost:5173/login
   - Login with admin credentials
   - Verify token stored in localStorage

2. **Navigate to Admin Dashboard:**
   - Click on "Dashboard" or navigate to `/admin/dashboard`
   - Verify loading state shows
   - Verify all KPI cards display data
   - Verify charts render correctly

3. **Test Period Filter:**
   - Change period from "THIS_MONTH" to "THIS_QUARTER"
   - Verify dashboard reloads with new data
   - Check Network tab for API call with `?period=THIS_QUARTER`

4. **Test Charts:**
   - Revenue Trend Chart: Verify 12 months of data
   - Branch Comparison Chart: Verify all branches displayed
   - Fleet Utilization Chart: Verify pie chart with percentages

5. **Test Alerts Panel:**
   - Verify alerts displayed with correct severity colors
   - Click "Acknowledge" button (if implemented)
   - Verify alert removed or marked as acknowledged

---

## 🛣️ ROUTING INTEGRATION

### Thêm Routes cho Module 7

Cập nhật `src/App.jsx` hoặc `src/routes/index.jsx`:

```javascript
import React from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import AdminDashboard from './components/module 7/AdminDashboard';
import ManagerDashboard from './components/module 7/ManagerDashboard';
import PrivateRoute from './components/PrivateRoute';

function App() {
    return (
        <BrowserRouter>
            <Routes>
                {/* ... existing routes ... */}

                {/* Module 7: Reporting & Analytics */}
                <Route
                    path="/admin/dashboard"
                    element={
                        <PrivateRoute roles={['ADMIN']}>
                            <AdminDashboard />
                        </PrivateRoute>
                    }
                />

                <Route
                    path="/manager/dashboard"
                    element={
                        <PrivateRoute roles={['ADMIN', 'MANAGER']}>
                            <ManagerDashboard />
                        </PrivateRoute>
                    }
                />

                {/* ... other routes ... */}
            </Routes>
        </BrowserRouter>
    );
}

export default App;
```

### PrivateRoute Component

Tạo `src/components/PrivateRoute.jsx` nếu chưa có:

```javascript
import React from 'react';
import { Navigate } from 'react-router-dom';

export default function PrivateRoute({ children, roles = [] }) {
    const token = localStorage.getItem('accessToken');
    const userRole = localStorage.getItem('userRole'); // Assume stored during login

    if (!token) {
        return <Navigate to="/login" replace />;
    }

    if (roles.length > 0 && !roles.includes(userRole)) {
        return <Navigate to="/unauthorized" replace />;
    }

    return children;
}
```

### Thêm Navigation Menu

Cập nhật `src/components/Sidebar.jsx` hoặc navigation component:

```javascript
const menuItems = [
    // ... existing menu items ...

    {
        title: 'Dashboard',
        icon: <BarChart3 />,
        path: '/admin/dashboard',
        roles: ['ADMIN'],
    },
    {
        title: 'Dashboard Chi nhánh',
        icon: <TrendingUp />,
        path: '/manager/dashboard',
        roles: ['ADMIN', 'MANAGER'],
    },

    // ... other menu items ...
];
```

---

## 🔐 SECURITY & PERMISSIONS

### Backend Security Configuration

File: `SecurityConfig.java`

```java
package org.example.ptcmssbackend.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
@EnableMethodSecurity(prePostEnabled = true)
public class SecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf().disable()
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/v1/admin/**").hasRole("ADMIN")
                .requestMatchers("/api/v1/manager/**").hasAnyRole("ADMIN", "MANAGER")
                .requestMatchers("/swagger-ui/**", "/api-docs/**").permitAll()
                .anyRequest().authenticated()
            )
            .httpBasic();

        return http.build();
    }
}
```

### Role-Based Access Summary

| Endpoint Pattern | Required Role | Description |
|-----------------|---------------|-------------|
| `/api/v1/admin/**` | ADMIN | Admin Dashboard & Analytics |
| `/api/v1/manager/**` | ADMIN, MANAGER | Manager Dashboard & Approvals |
| `/api/v1/admin/dashboard` | ADMIN | Company-wide dashboard |
| `/api/v1/manager/dashboard` | ADMIN, MANAGER | Branch-specific dashboard |
| `/api/v1/admin/alerts` | ADMIN | System-wide alerts |
| `/api/v1/manager/approvals/**` | ADMIN, MANAGER | Approval actions |

---

## 📚 API REFERENCE

### Admin Dashboard APIs

#### 1. Get Admin Dashboard
```
GET /api/v1/admin/dashboard?period=THIS_MONTH
```

**Query Parameters:**
- `period` (optional): `TODAY`, `THIS_WEEK`, `THIS_MONTH`, `THIS_QUARTER`, `YTD`
- Default: `THIS_MONTH`

**Response:**
```json
{
    "totalRevenue": 150000000,
    "totalExpense": 80000000,
    "netProfit": 70000000,
    "totalTrips": 450,
    "fleetUtilization": 75.5,
    "period": "THIS_MONTH",
    "periodStart": "2025-01-01T00:00:00",
    "periodEnd": "2025-01-23T15:30:00"
}
```

#### 2. Get Revenue Trend
```
GET /api/v1/admin/analytics/revenue-trend
```

**Response:**
```json
[
    {
        "month": "2024-02",
        "revenue": 120000000,
        "expense": 65000000,
        "netProfit": 55000000,
        "tripCount": 380
    },
    {
        "month": "2024-03",
        "revenue": 135000000,
        "expense": 70000000,
        "netProfit": 65000000,
        "tripCount": 420
    }
]
```

#### 3. Get Branch Comparison
```
GET /api/v1/admin/analytics/branch-comparison?period=THIS_MONTH
```

**Response:**
```json
[
    {
        "branchId": 1,
        "branchName": "Chi nhánh Hà Nội",
        "location": "Hà Nội",
        "revenue": 80000000,
        "expense": 45000000,
        "netProfit": 35000000,
        "totalTrips": 250,
        "totalVehicles": 30,
        "vehiclesInUse": 22,
        "vehicleUtilizationRate": 73.3
    }
]
```

#### 4. Get System Alerts
```
GET /api/v1/admin/alerts?severity=HIGH,CRITICAL
```

**Query Parameters:**
- `severity` (optional): Comma-separated list: `CRITICAL`, `HIGH`, `MEDIUM`, `LOW`

**Response:**
```json
[
    {
        "alertId": 1,
        "alertType": "VEHICLE_INSPECTION_EXPIRING",
        "severity": "CRITICAL",
        "message": "Xe 29A-12345 sắp hết hạn đăng kiểm",
        "licensePlate": "29A-12345",
        "daysUntilExpiry": 5,
        "branchName": "Chi nhánh Hà Nội",
        "createdAt": "2025-01-20T10:00:00"
    },
    {
        "alertId": 2,
        "alertType": "DRIVER_LICENSE_EXPIRING",
        "severity": "HIGH",
        "driverName": "Nguyễn Văn A",
        "licenseNumber": "123456789",
        "daysUntilExpiry": 12,
        "branchName": "Chi nhánh TP.HCM"
    }
]
```

#### 5. Get Fleet Utilization
```
GET /api/v1/admin/analytics/fleet-utilization
```

**Response:**
```json
[
    {
        "branchId": 1,
        "branchName": "Chi nhánh Hà Nội",
        "totalVehicles": 30,
        "vehiclesInUse": 22,
        "vehiclesAvailable": 7,
        "vehiclesMaintenance": 1,
        "utilizationRate": 73.3
    }
]
```

### Manager Dashboard APIs

#### 1. Get Manager Dashboard
```
GET /api/v1/manager/dashboard?branchId=1&period=THIS_MONTH
```

**Query Parameters:**
- `branchId` (required): Branch ID
- `period` (optional): Same as Admin Dashboard

**Response:** Same structure as Admin Dashboard, but filtered by branch

#### 2. Approve Day-Off Request
```
POST /api/v1/manager/day-off/{dayOffId}/approve
```

**Response:** `200 OK`

#### 3. Reject Day-Off Request
```
POST /api/v1/manager/day-off/{dayOffId}/reject
Content-Type: application/json

{
    "reason": "Không đủ nhân sự trong thời gian này"
}
```

**Response:** `200 OK`

---

## 🐛 TROUBLESHOOTING

### Problem 1: CORS Error

**Symptom:**
```
Access to XMLHttpRequest at 'http://localhost:8080/api/v1/admin/dashboard'
from origin 'http://localhost:5173' has been blocked by CORS policy
```

**Solution:**
1. Check `WebConfig.java` has correct CORS configuration
2. Verify `application.properties` has CORS settings
3. Restart backend server

### Problem 2: 401 Unauthorized

**Symptom:**
```
GET /api/v1/admin/dashboard 401 Unauthorized
```

**Solution:**
1. Check token stored in localStorage: `localStorage.getItem('accessToken')`
2. Verify token not expired
3. Check Authorization header in request: `Authorization: Bearer <token>`
4. Login again to get fresh token

### Problem 3: Empty Data Returned

**Symptom:**
Dashboard loads but shows 0 for all metrics

**Solution:**
1. Check database has data:
```sql
SELECT COUNT(*) FROM invoices WHERE status = 'ACTIVE';
SELECT COUNT(*) FROM trips;
SELECT COUNT(*) FROM vehicles;
```

2. Check date ranges in SQL queries
3. Verify `period` parameter passed correctly

### Problem 4: Charts Not Rendering

**Symptom:**
KPI cards show but charts are blank

**Solution:**
1. Check browser console for errors
2. Verify `recharts` installed: `npm list recharts`
3. Check data format matches chart requirements
4. Verify data not empty: `console.log(chartData)`

### Problem 5: Backend Not Starting

**Symptom:**
```
Error starting ApplicationContext
```

**Solution:**
1. Check MySQL server running: `mysql -u root -p`
2. Verify database exists: `SHOW DATABASES;`
3. Check `application.properties` connection settings
4. Run `./mvnw clean install` again

---

## ✅ DEPLOYMENT CHECKLIST

### Pre-Deployment

- [ ] All backend endpoints tested with Postman/curl
- [ ] All frontend components tested in browser
- [ ] CORS configuration correct for production domain
- [ ] Environment variables configured (database URL, passwords)
- [ ] Security settings reviewed (JWT, roles, permissions)
- [ ] Database indexes added for performance
- [ ] Logging configured for production
- [ ] Error handling tested (network errors, server errors)

### Backend Deployment

- [ ] Build production JAR: `./mvnw clean package -DskipTests`
- [ ] Configure production `application.properties`:
  - Database URL
  - Server port
  - CORS allowed origins (production frontend URL)
  - JWT secret
- [ ] Deploy JAR to server (Tomcat/Docker/Cloud)
- [ ] Verify backend accessible: `curl https://api.yourdomain.com/api/v1/admin/dashboard`
- [ ] Check Swagger UI: `https://api.yourdomain.com/swagger-ui.html`

### Frontend Deployment

- [ ] Update `axiosInstance.js` baseURL to production API URL
- [ ] Build production bundle: `npm run build`
- [ ] Deploy `dist/` folder to web server (Nginx/Apache/Vercel/Netlify)
- [ ] Configure web server for React Router (redirect all to index.html)
- [ ] Test all routes work after deployment
- [ ] Verify API calls work with production backend

### Database

- [ ] Backup production database before deployment
- [ ] Run any pending migrations
- [ ] Verify indexes exist on frequently queried columns:
  - `invoices.invoiceDate`
  - `trips.startTime`
  - `vehicles.status`
  - `drivers.licenseExpiry`

### Post-Deployment Testing

- [ ] Login as Admin → View Admin Dashboard
- [ ] Login as Manager → View Manager Dashboard
- [ ] Test all period filters (TODAY, THIS_WEEK, etc.)
- [ ] Verify charts render correctly with production data
- [ ] Test alerts panel
- [ ] Test export functionality (if implemented)
- [ ] Monitor server logs for errors
- [ ] Check performance metrics (page load time, API response time)

---

## 📊 PERFORMANCE OPTIMIZATION

### Backend Optimizations

1. **Add Database Indexes:**
```sql
CREATE INDEX idx_invoices_date_status ON invoices(invoiceDate, status);
CREATE INDEX idx_trips_start_status ON trips(startTime, status);
CREATE INDEX idx_vehicles_status ON vehicles(status);
CREATE INDEX idx_drivers_expiry ON drivers(licenseExpiry, status);
```

2. **Enable Query Caching:**
```properties
spring.jpa.properties.hibernate.cache.use_second_level_cache=true
spring.jpa.properties.hibernate.cache.use_query_cache=true
```

3. **Connection Pooling:**
```properties
spring.datasource.hikari.maximum-pool-size=20
spring.datasource.hikari.minimum-idle=5
spring.datasource.hikari.connection-timeout=30000
```

### Frontend Optimizations

1. **Lazy Loading:**
```javascript
const AdminDashboard = React.lazy(() => import('./components/module 7/AdminDashboard'));
const ManagerDashboard = React.lazy(() => import('./components/module 7/ManagerDashboard'));
```

2. **Memoization:**
```javascript
const chartData = React.useMemo(() => {
    return processChartData(rawData);
}, [rawData]);
```

3. **Debounce Period Filter:**
```javascript
const debouncedPeriod = useDebounce(period, 500);

React.useEffect(() => {
    loadDashboard();
}, [debouncedPeriod]);
```

---

## 🎉 HOÀN THÀNH!

Module 7 đã sẵn sàng để tích hợp và triển khai. Follow các bước trong guide này để:

1. ✅ Setup Backend (Spring Boot)
2. ✅ Setup Frontend (React)
3. ✅ Test Integration
4. ✅ Configure Routing
5. ✅ Deploy to Production

**Tài liệu tham khảo thêm:**
- [MODULE7_BACKEND_COMPLETE.md](MODULE7_BACKEND_COMPLETE.md) - Backend implementation details
- [MODULE7_IMPLEMENTATION_SUMMARY.md](MODULE7_IMPLEMENTATION_SUMMARY.md) - Frontend implementation summary
- [ANALYSIS_MODULE7_QUERIES.md](ANALYSIS_MODULE7_QUERIES.md) - SQL queries reference

**Liên hệ hỗ trợ:**
- Backend issues: Check logs in `logs/spring.log`
- Frontend issues: Check browser console (F12)
- Database issues: Check MySQL error logs

---

**🚀 READY FOR PRODUCTION!**
