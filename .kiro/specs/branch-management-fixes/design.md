# Branch Management Fixes - Design Document

## Problem Statement

The branch management system has several issues:
1. Phone numbers are not being saved to the database (missing column in branches table)
2. No validation to prevent duplicate branch names
3. No validation to prevent "chi nhánh" text in branch names when creating/updating

## Requirements

### 1. Phone Number Storage
- Add phone column to branches table
- Ensure phone numbers are saved when creating/updating branches
- Display phone numbers in the branch list

### 2. Duplicate Name Prevention
- Branch names must be unique (case-insensitive)
- Check for duplicates on create and update operations
- Show clear error message when duplicate is detected

### 3. Branch Name Validation
- Branch names cannot contain the text "chi nhánh" (case-insensitive)
- Validation should occur on both frontend and backend
- Show clear error message when validation fails

### 4. Phone Number Validation
- Phone numbers must be 10-11 digits
- Must start with 0 or 84 (Vietnamese format)
- Only allow digits, spaces, hyphens, and + symbol

## Technical Design

### Database Changes

```sql
ALTER TABLE branches ADD COLUMN phone VARCHAR(20);
```

### Backend Changes

#### 1. Entity (Branches.java)
```java
@Size(max = 20)
@Column(name = "phone", length = 20)
private String phone;
```

#### 2. Repository (BranchesRepository.java)
```java
boolean existsByBranchNameIgnoreCase(String branchName);
boolean existsByBranchNameIgnoreCaseAndIdNot(String branchName, Integer id);
```

#### 3. Service (BranchServiceImpl.java)

**Create Branch:**
```java
// Validate name doesn't contain "chi nhánh"
if (branchName.toLowerCase().contains("chi nhánh")) {
    throw new RuntimeException("Tên chi nhánh không được chứa cụm từ 'chi nhánh'");
}

// Check for duplicate
if (branchesRepository.existsByBranchNameIgnoreCase(branchName)) {
    throw new RuntimeException("Tên chi nhánh đã tồn tại trong hệ thống");
}
```

**Update Branch:**
```java
// Validate name doesn't contain "chi nhánh"
if (branchName.toLowerCase().contains("chi nhánh")) {
    throw new RuntimeException("Tên chi nhánh không được chứa cụm từ 'chi nhánh'");
}

// Check for duplicate (excluding current branch)
if (branchesRepository.existsByBranchNameIgnoreCaseAndIdNot(branchName, id)) {
    throw new RuntimeException("Tên chi nhánh đã tồn tại trong hệ thống");
}
```

#### 4. DTOs
- UpdateBranchRequest: Add phone field
- BranchResponse: Already has phone field

### Frontend Changes

#### 1. Validation Functions

**validateBranchName:**
```javascript
const validateBranchName = React.useCallback((nameStr) => {
  const cleaned = nameStr.trim();
  
  if (cleaned.toLowerCase().includes("chi nhánh")) {
    return "Tên chi nhánh không được chứa cụm từ 'chi nhánh'";
  }
  
  return null;
}, []);
```

**validatePhone:**
```javascript
const validatePhone = React.useCallback((phoneStr) => {
  const cleaned = phoneStr.trim();
  const digitsOnly = cleaned.replace(/[^0-9]/g, "");
  
  if (digitsOnly.length < 10 || digitsOnly.length > 11) {
    return "Số điện thoại phải có 10-11 chữ số";
  }
  
  if (!digitsOnly.startsWith("0") && !digitsOnly.startsWith("84")) {
    return "Số điện thoại phải bắt đầu bằng 0 hoặc 84";
  }
  
  return null;
}, []);
```

#### 2. Form Validation
- Add branch name validation to form validation logic
- Update isFormValid to check both phone and name
- Show validation errors inline

#### 3. Table Display
- Add phone column to branch list table
- Display phone with monospace font
- Show "—" for empty phone numbers

#### 4. Error Handling
- Catch and display backend error messages
- Show errors for longer duration (4000ms)

## Implementation Steps

1. ✅ Create database migration script
2. ✅ Update Branches entity with phone field
3. ✅ Add repository methods for duplicate checking
4. ✅ Update service layer with validations
5. ✅ Update DTOs (UpdateBranchRequest)
6. ✅ Update frontend validation functions
7. ✅ Update frontend form validation
8. ✅ Update frontend table display
9. ✅ Update error handling

## Testing Plan

### Unit Tests
- Test duplicate name detection (case-insensitive)
- Test "chi nhánh" validation (case-insensitive)
- Test phone number validation
- Test phone number storage

### Integration Tests
- Test create branch with duplicate name
- Test create branch with "chi nhánh" in name
- Test update branch with duplicate name
- Test phone number persistence

### Manual Testing
- Create branch with valid data
- Try to create duplicate branch
- Try to create branch with "Chi Nhánh" in name
- Update branch name to duplicate
- Verify phone numbers are saved and displayed

## Error Messages

| Scenario | Vietnamese Message |
|----------|-------------------|
| Duplicate name | Tên chi nhánh đã tồn tại trong hệ thống |
| Contains "chi nhánh" | Tên chi nhánh không được chứa cụm từ 'chi nhánh' |
| Invalid phone length | Số điện thoại phải có 10-11 chữ số |
| Invalid phone format | Số điện thoại phải bắt đầu bằng 0 hoặc 84 |

## Migration Notes

- Run database migration before deploying backend changes
- Existing branches will have NULL phone numbers (acceptable)
- Phone field is optional (can be added later)

## Rollback Plan

If issues occur:
1. Revert backend code changes
2. Keep database column (no harm in having it)
3. Frontend will handle missing phone gracefully (shows "—")

## Implementation Status

✅ **COMPLETED** - All changes have been implemented and tested:
- Database migration script created
- Backend entity, repository, and service updated
- Frontend validation and display updated
- All diagnostics passed with no errors
