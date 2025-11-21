# ResponseData Usage Guide

## 📋 Cấu trúc ResponseData

```java
public class ResponseData<T> {
    private final int status;
    private final String message;
    @JsonInclude(JsonInclude.Include.NON_NULL)
    private T data;
    
    // Constructor với data (GET, POST)
    public ResponseData(int status, String message, T data)
    
    // Constructor không có data (PUT, PATCH, DELETE)
    public ResponseData(int status, String message)
}
```

## ✅ Cách sử dụng đúng

### 1. Success response với data (GET, POST)
```java
@GetMapping("/{id}")
public ResponseEntity<ResponseData<User>> getUser(@PathVariable Integer id) {
    User user = userService.findById(id);
    return ResponseEntity.ok(new ResponseData<>(200, "Success", user));
}

@PostMapping
public ResponseEntity<ResponseData<User>> createUser(@RequestBody UserRequest request) {
    User user = userService.create(request);
    return ResponseEntity.ok(new ResponseData<>(200, "User created successfully", user));
}
```

### 2. Success response không có data (PUT, PATCH, DELETE)
```java
@PutMapping("/{id}")
public ResponseEntity<ResponseData<Void>> updateUser(@PathVariable Integer id, @RequestBody UserRequest request) {
    userService.update(id, request);
    return ResponseEntity.ok(new ResponseData<>(200, "User updated successfully"));
}

@DeleteMapping("/{id}")
public ResponseEntity<ResponseData<Void>> deleteUser(@PathVariable Integer id) {
    userService.delete(id);
    return ResponseEntity.ok(new ResponseData<>(200, "User deleted successfully"));
}
```

### 3. Error response
```java
@GetMapping("/{id}")
public ResponseEntity<ResponseData<User>> getUser(@PathVariable Integer id) {
    try {
        User user = userService.findById(id);
        return ResponseEntity.ok(new ResponseData<>(200, "Success", user));
    } catch (NotFoundException e) {
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
            .body(new ResponseData<>(404, "User not found"));
    } catch (Exception e) {
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
            .body(new ResponseData<>(500, e.getMessage()));
    }
}
```

### 4. Response với data null
```java
@GetMapping("/optional/{id}")
public ResponseEntity<ResponseData<User>> getOptionalUser(@PathVariable Integer id) {
    User user = userService.findByIdOptional(id);
    if (user == null) {
        return ResponseEntity.ok(new ResponseData<>(200, "No user found", null));
    }
    return ResponseEntity.ok(new ResponseData<>(200, "Success", user));
}
```

## 🎯 HTTP Status Codes

| Status | Code | Khi nào dùng |
|--------|------|--------------|
| OK | 200 | Request thành công |
| Created | 201 | Tạo resource mới thành công |
| Bad Request | 400 | Validation error, invalid input |
| Unauthorized | 401 | Chưa đăng nhập |
| Forbidden | 403 | Không có quyền truy cập |
| Not Found | 404 | Resource không tồn tại |
| Internal Server Error | 500 | Lỗi server |

## 📝 Examples từ RatingController

```java
// POST - Create rating
@PostMapping
public ResponseEntity<ResponseData<RatingResponse>> createRating(@RequestBody RatingRequest request) {
    try {
        RatingResponse response = ratingService.createRating(request, userId);
        return ResponseEntity.ok(new ResponseData<>(200, "Rating created successfully", response));
    } catch (Exception e) {
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
            .body(new ResponseData<>(400, e.getMessage()));
    }
}

// GET - Get rating by trip
@GetMapping("/trip/{tripId}")
public ResponseEntity<ResponseData<RatingResponse>> getRatingByTrip(@PathVariable Integer tripId) {
    try {
        RatingResponse response = ratingService.getRatingByTrip(tripId);
        if (response == null) {
            return ResponseEntity.ok(new ResponseData<>(200, "No rating found for this trip", null));
        }
        return ResponseEntity.ok(new ResponseData<>(200, "Success", response));
    } catch (Exception e) {
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
            .body(new ResponseData<>(500, e.getMessage()));
    }
}

// GET - Get list
@GetMapping("/driver/{driverId}")
public ResponseEntity<ResponseData<List<RatingResponse>>> getDriverRatings(@PathVariable Integer driverId) {
    try {
        List<RatingResponse> ratings = ratingService.getDriverRatings(driverId, limit);
        return ResponseEntity.ok(new ResponseData<>(200, "Success", ratings));
    } catch (Exception e) {
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
            .body(new ResponseData<>(500, e.getMessage()));
    }
}
```

## ❌ Sai lầm thường gặp

### 1. Dùng static methods không tồn tại
```java
// SAI ❌
return ResponseEntity.ok(ResponseData.success(data));
return ResponseEntity.ok(ResponseData.error("Error"));

// ĐÚNG ✅
return ResponseEntity.ok(new ResponseData<>(200, "Success", data));
return ResponseEntity.status(500).body(new ResponseData<>(500, "Error"));
```

### 2. Quên import đúng package
```java
// SAI ❌
import org.example.ptcmssbackend.dto.ResponseData;

// ĐÚNG ✅
import org.example.ptcmssbackend.dto.response.common.ResponseData;
```

### 3. Status code không khớp với HTTP status
```java
// SAI ❌
return ResponseEntity.status(HttpStatus.NOT_FOUND)
    .body(new ResponseData<>(200, "Not found")); // Status 200 nhưng HTTP 404

// ĐÚNG ✅
return ResponseEntity.status(HttpStatus.NOT_FOUND)
    .body(new ResponseData<>(404, "Not found"));
```

## 🔍 JSON Response Format

### Success với data
```json
{
  "status": 200,
  "message": "Success",
  "data": {
    "id": 1,
    "name": "John Doe"
  }
}
```

### Success không có data
```json
{
  "status": 200,
  "message": "User deleted successfully"
}
```

### Error
```json
{
  "status": 404,
  "message": "User not found"
}
```

### Success với data null
```json
{
  "status": 200,
  "message": "No rating found for this trip",
  "data": null
}
```

Note: Field `data` sẽ không xuất hiện trong JSON nếu null (do `@JsonInclude(JsonInclude.Include.NON_NULL)`)
