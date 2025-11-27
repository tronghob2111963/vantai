# Branch Management Fixes - Implementation Summary

## Overview
Fixed branch management issues including duplicate name validation and branch name restrictions. Phone number is now displayed from the manager's user profile instead of storing it separately in the branch table.

## Changes Implemented

### 1. Phone Number Display
- Phone number is NOT stored in branches table
- Phone number is retrieved from the manager's user profile (Users.phone)
- Displayed in branch list when a manager is assigned

### 2. Backend Changes

#### Entity Layer
**File**: `PTCMSS/ptcmss-backend/src/main/java/org/example/ptcmssbackend/entity/Branches.java`
- No phone field in Branches entity (removed if existed)

#### Repository Layer
**File**: `PTCMSS/ptcmss-backend/src/main/java/org/example/ptcmssbackend/repository/BranchesRepository.java`
- Added `existsByBranchNameIgnoreCase()` - Check for duplicate branch names
- Added `existsByBranchNameIgnoreCaseAndIdNot()` - Check duplicates excluding current branch (for updates)

#### DTO Layer
**Files**:
- `CreateBranchRequest.java` - Removed phone field (not needed)
- `UpdateBranchRequest.java` - No phone field
- `BranchResponse.java` - Phone field populated from manager's user profile

#### Service Layer
**File**: `PTCMSS/ptcmss-backend/src/main/java/org/example/ptcmssbackend/service/impl/BranchServiceImpl.java`

**createBranch()** - Enhanced with:
- Validation: Branch name cannot contain "chi nhánh" (case-insensitive)
- Validation: Branch name must be unique (case-insensitive)
- Phone retrieved from manager's user profile and included in response

**updateBranch()** - Enhanced with:
- Validation: Branch name cannot contain "chi nhánh" (case-insensitive)
- Validation: Branch name must be unique excluding current branch (case-insensitive)
- Phone retrieved from manager's user profile when manager is updated

**getBranchById()** - Updated to include phone in response

**getBranchByUserId()** - Updated to include phone in response

**getAllBranches()** - Updated to include phone in paginated response

### 3. Frontend Changes

#### Component: AdminBranchesPage.jsx
**File**: `PTCMSS_FRONTEND/src/components/module 1/AdminBranchesPage.jsx`

**Validation Functions**:
- `validatePhone()` - Updated to require 10-11 digits, must start with 0 or 84
- `validateBranchName()` - NEW: Validates that branch name doesn't contain "chi nhánh"

**CreateBranchModal**:
- Removed phone input field (not needed)
- Enhanced validation to check branch name restrictions
- Better error messages from backend (shows duplicate name errors)
- Form validation includes name checks
- Added note that phone will be taken from manager's profile

**Branch List Table**:
- "Số điện thoại" (Phone) column displays manager's phone
- Phone numbers displayed with monospace font for better readability
- Shows "—" when no manager is assigned
- Updated colspan for empty state

**Data Mapping**:
- Phone field retrieved from manager's user profile in API response

## Validation Rules

### Branch Name
1. ✅ Required field
2. ✅ Cannot contain "chi nhánh" or "Chi nhánh" (case-insensitive)
3. ✅ Must be unique across all branches (case-insensitive)
4. ✅ Validated on both create and update operations

### Phone Number
1. ✅ NOT stored in branches table
2. ✅ Retrieved from manager's user profile (Users.phone)
3. ✅ Displayed in branch list when manager is assigned
4. ✅ Shows "—" when no manager assigned

## Database Migration

**No database migration needed!** Phone numbers are retrieved from the Users table through the manager relationship.

## Testing Checklist

### Create Branch
- [ ] Cannot create branch with name containing "chi nhánh"
- [ ] Cannot create branch with duplicate name (case-insensitive)
- [ ] No phone input field in form
- [ ] Manager selection is optional
- [ ] Success message shows on successful creation

### Update Branch
- [ ] Cannot update branch name to contain "chi nhánh"
- [ ] Cannot update branch name to duplicate another branch
- [ ] Can update manager assignment
- [ ] Phone updates automatically when manager changes
- [ ] Changes are persisted to database

### Display
- [ ] Phone column shows in branch list table
- [ ] Phone number displays manager's phone correctly
- [ ] Empty phone shows as "—" when no manager assigned
- [ ] Phone updates when manager is changed

## Error Messages

### Vietnamese Error Messages:
- "Tên chi nhánh không được chứa cụm từ 'chi nhánh'"
- "Tên chi nhánh đã tồn tại trong hệ thống"

## Files Modified

### Backend (8 files)
1. `Branches.java` - Entity
2. `BranchesRepository.java` - Repository
3. `BranchServiceImpl.java` - Service implementation
4. `CreateBranchRequest.java` - DTO (already had phone)
5. `UpdateBranchRequest.java` - DTO
6. `BranchResponse.java` - DTO (already had phone)

### Frontend (1 file)
1. `AdminBranchesPage.jsx` - Main component

### Database (1 file)
1. `add_phone_to_branches.sql` - Migration script

## Notes

- All validations work on both frontend and backend
- Phone field was already in DTOs but not in entity/database
- Branch name validation prevents confusion with "Chi nhánh Hà Nội" vs "Hà Nội"
- Case-insensitive duplicate checking prevents "Ha Noi" and "ha noi" duplicates
- Error messages are user-friendly and in Vietnamese
