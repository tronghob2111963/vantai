# PROMPT: Redesign Trang "Thông tin người dùng" (UserDetailPage)

## Yêu cầu

Redesign trang **UserDetailPage** (`PTCMSS_FRONTEND/src/components/module 1/UserDetailPage.jsx`) với UI hiện đại, đẹp mắt và nhất quán với theme hiện tại của hệ thống.

## Thiết kế yêu cầu

### 1. Header Section
- **Background gradient**: Từ `#0079BC` đến `#005a8a` (brand color gradient)
- **Title**: "Thông tin người dùng" với icon `User` hoặc `UserCog`
- **Subtitle**: "Chỉnh sửa thông tin tài khoản người dùng"
- **Back button**: Icon `ArrowLeft` với hover effect, đặt bên trái header
- **Save button**: Gradient button với icon `Save`, đặt bên phải header
- **Shadow**: Subtle shadow cho header

### 2. Form Layout
- **Container**: Max-width container (ví dụ: `max-w-4xl mx-auto`)
- **Card design**: White card với rounded corners (`rounded-2xl`), shadow nhẹ
- **Section dividers**: Chia form thành các sections với icons:
  - **Thông tin cá nhân**: Icon `User`, `Mail`, `Phone`, `MapPin`
  - **Phân quyền**: Icon `Shield`
  - **Trạng thái**: Icon `CheckCircle` hoặc `XCircle`

### 3. Form Fields
- **Icons**: Mỗi field có icon tương ứng bên trái
- **Labels**: Font weight medium, màu slate-700
- **Inputs**: 
  - Border: `border-slate-300`
  - Focus: `focus:ring-2 focus:ring-[#0079BC]/20 focus:border-[#0079BC]`
  - Hover: `hover:border-slate-400`
  - Padding: `px-4 py-3`
  - Rounded: `rounded-lg`
- **Error states**: 
  - Border red: `border-rose-400`
  - Error message: Text red nhỏ, icon `AlertCircle`
- **Placeholder**: Màu slate-400

### 4. Select Dropdowns
- **Vai trò**: Dropdown với icon `Shield`
- **Trạng thái**: Dropdown với icon động (ACTIVE = `CheckCircle`, INACTIVE = `XCircle`)
- **Styling**: Giống input fields, có chevron down icon

### 5. Buttons
- **Save button**: 
  - Gradient: `bg-gradient-to-r from-[#0079BC] to-[#005a8a]`
  - Hover: `hover:from-[#005a8a] hover:to-[#0079BC]`
  - Shadow: `shadow-lg shadow-[#0079BC]/30`
  - Disabled: Opacity 50%
- **Back button**: 
  - Outline style: `border border-slate-300`
  - Hover: `hover:bg-slate-50`

### 6. Error Display
- **General error**: 
  - Background: `bg-gradient-to-r from-rose-50 to-red-50`
  - Border: `border-rose-200`
  - Icon: `XCircle` màu rose-600
  - Animation: Fade in
- **Field errors**: 
  - Text nhỏ: `text-xs`
  - Màu: `text-rose-600`
  - Icon: `AlertCircle` nhỏ

### 7. Loading States
- **Loading overlay**: Khi đang load user data
- **Saving state**: Button disabled với spinner hoặc "Đang lưu..."

### 8. Responsive Design
- **Mobile**: Form stack vertically, full width
- **Tablet/Desktop**: Max-width container, centered

### 9. Animations & Transitions
- **Form fields**: Smooth transitions khi focus
- **Buttons**: Scale effect khi hover (`hover:scale-[1.02]`)
- **Error messages**: Fade in animation
- **Card**: Subtle shadow on hover

### 10. Brand Consistency
- **Brand color**: `#0079BC` cho accents, buttons, focus states
- **Typography**: Inter/Sans-serif
- **Spacing**: Consistent padding và margins
- **Shadows**: Subtle, consistent shadow system

## Technical Requirements

1. **Icons**: Sử dụng `lucide-react` icons
2. **Styling**: Tailwind CSS với custom brand color
3. **Validation**: Giữ nguyên logic validation hiện tại
4. **API**: Giữ nguyên API calls (`getUser`, `updateUser`, `listRoles`)
5. **Navigation**: Giữ nguyên `useNavigate` và `useParams`
6. **State management**: Giữ nguyên React state management

## Visual Reference

Tham khảo design của:
- `AdminCreateUserPage.jsx` - Form layout với icons
- `AdminBranchesPage.jsx` - Header design với gradient
- `UpdateProfilePage.jsx` - Card design và spacing

## Expected Outcome

Trang UserDetailPage với:
- ✅ Header đẹp với gradient brand color
- ✅ Form fields có icons và focus states rõ ràng
- ✅ Error handling với animations
- ✅ Responsive design
- ✅ Consistent với theme hệ thống
- ✅ Professional và modern UI

