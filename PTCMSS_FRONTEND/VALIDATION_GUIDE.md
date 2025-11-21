# 📋 Form Validation Guide

## 🎯 Tổng quan

Project đã có hệ thống validation hoàn chỉnh với:
- ✅ Validation utilities tái sử dụng
- ✅ Custom hook `useFormValidation`
- ✅ Reusable `FormInput` component
- ✅ Validation cho: Email, Phone, Username, Password, Number, Date, License Plate, etc.

---

## 📁 Files đã tạo

```
PTCMSS_FRONTEND/
├── src/
│   ├── utils/
│   │   └── validation.js          ← Validation functions
│   ├── hooks/
│   │   └── useFormValidation.js   ← Custom hook
│   └── components/
│       └── common/
│           └── FormInput.jsx      ← Input component với validation
```

---

## 🚀 Cách sử dụng

### Cách 1: Sử dụng Custom Hook (Recommended)

```jsx
import { useFormValidation } from '../../hooks/useFormValidation';
import { validateEmail, validatePhone, validateRequired } from '../../utils/validation';
import FormInput from '../common/FormInput';

function MyForm() {
  const { values, errors, handleChange, handleBlur, validateAll } = useFormValidation(
    // Initial values
    { 
      email: '', 
      phone: '',
      fullName: ''
    },
    // Validation rules
    {
      email: [
        (v) => validateRequired(v, 'Email'),
        validateEmail
      ],
      phone: [
        (v) => validateRequired(v, 'Số điện thoại'),
        validatePhone
      ],
      fullName: [
        (v) => validateRequired(v, 'Họ tên')
      ]
    }
  );

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    // Validate all fields
    if (!validateAll()) {
      return; // Has errors
    }
    
    // Submit form
    await submitData(values);
  };

  return (
    <form onSubmit={handleSubmit}>
      <FormInput
        label="Họ tên"
        name="fullName"
        value={values.fullName}
        onChange={handleChange}
        onBlur={handleBlur}
        error={errors.fullName}
        required
      />
      
      <FormInput
        label="Email"
        name="email"
        type="email"
        value={values.email}
        onChange={handleChange}
        onBlur={handleBlur}
        error={errors.email}
        required
      />
      
      <FormInput
        label="Số điện thoại"
        name="phone"
        value={values.phone}
        onChange={handleChange}
        onBlur={handleBlur}
        error={errors.phone}
        required
      />
      
      <button type="submit">Lưu</button>
    </form>
  );
}
```

### Cách 2: Sử dụng Validation Functions trực tiếp

```jsx
import { validateEmail, validatePhone } from '../../utils/validation';

function MyForm() {
  const [email, setEmail] = useState('');
  const [emailError, setEmailError] = useState('');

  const handleEmailChange = (e) => {
    const value = e.target.value;
    setEmail(value);
    setEmailError(validateEmail(value));
  };

  return (
    <input 
      value={email}
      onChange={handleEmailChange}
      className={emailError ? 'border-red-400' : ''}
    />
  );
}
```

---

## 📚 Available Validation Functions

### 1. Email Validation
```javascript
import { validateEmail } from '../utils/validation';

const error = validateEmail('test@example.com');
// Returns: "" (valid) or "Email không đúng định dạng"
```

### 2. Phone Validation
```javascript
import { validatePhone } from '../utils/validation';

const error = validatePhone('0123456789');
// Returns: "" (valid) or "Số điện thoại phải có 10 chữ số..."
```

### 3. Required Field
```javascript
import { validateRequired } from '../utils/validation';

const error = validateRequired('', 'Họ tên');
// Returns: "Họ tên là bắt buộc"
```

### 4. Username
```javascript
import { validateUsername } from '../utils/validation';

const error = validateUsername('user123');
// Checks: 3-50 chars, alphanumeric + underscore only
```

### 5. Password
```javascript
import { validatePassword } from '../utils/validation';

const error = validatePassword('pass123');
// Checks: min 6 chars, max 100 chars
```

### 6. Number
```javascript
import { validateNumber } from '../utils/validation';

const error = validateNumber(50, 0, 100, 'Tuổi');
// Checks: is number, min 0, max 100
```

### 7. License Plate
```javascript
import { validateLicensePlate } from '../utils/validation';

const error = validateLicensePlate('29A-12345');
// Checks: Vietnamese format
```

### 8. Date
```javascript
import { validateDate, validateDateRange } from '../utils/validation';

const error1 = validateDate('2024-01-01', 'Ngày sinh');
const error2 = validateDateRange('2024-01-01', '2024-12-31');
```

---

## 🎨 FormInput Component Props

```jsx
<FormInput
  label="Label text"           // Optional
  name="fieldName"             // Required
  value={value}                // Required
  onChange={handleChange}      // Required: (name, value) => void
  onBlur={handleBlur}          // Optional: (name) => void
  error={errorMessage}         // Optional: string
  type="text"                  // Optional: text, email, password, number, etc.
  placeholder="..."            // Optional
  required={true}              // Optional: shows red asterisk
  disabled={false}             // Optional
  className="..."              // Optional: additional classes
/>
```

---

## 🔄 Updating Existing Forms

### Before (Manual validation):
```jsx
const [email, setEmail] = useState('');
const [emailError, setEmailError] = useState('');

const validateEmail = (value) => {
  if (!value) return "";
  const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return re.test(value) ? "" : "Email không đúng định dạng";
};

useEffect(() => {
  setEmailError(validateEmail(email));
}, [email]);
```

### After (Using hook):
```jsx
import { useFormValidation } from '../../hooks/useFormValidation';
import { validateEmail, validateRequired } from '../../utils/validation';

const { values, errors, handleChange, handleBlur } = useFormValidation(
  { email: '' },
  { email: [validateRequired, validateEmail] }
);
```

---

## ✅ Checklist: Update Form

- [ ] Import `useFormValidation` hook
- [ ] Import validation functions từ `utils/validation`
- [ ] Replace useState với useFormValidation
- [ ] Replace input elements với `FormInput` component
- [ ] Add validation rules
- [ ] Call `validateAll()` before submit
- [ ] Test validation với các cases: empty, invalid format, valid

---

## 🧪 Test Cases

### Email:
- ✅ Valid: `test@example.com`
- ❌ Invalid: `test`, `test@`, `@example.com`

### Phone:
- ✅ Valid: `0123456789`, `0987654321`
- ❌ Invalid: `123456789` (không bắt đầu bằng 0), `01234` (không đủ 10 số)

### Username:
- ✅ Valid: `user123`, `john_doe`
- ❌ Invalid: `ab` (< 3 chars), `user@123` (có ký tự đặc biệt)

### License Plate:
- ✅ Valid: `29A-12345`, `30B12345`
- ❌ Invalid: `ABC123`, `29-12345`

---

## 📝 Next Steps

1. **Update AdminCreateUserPage** ✅ (Đã có validation)
2. **Update CreateOrderPage** - Thêm validation cho form tạo đơn hàng
3. **Update VehicleCreatePage** - Thêm validation cho biển số xe
4. **Update DriverProfilePage** - Thêm validation cho GPLX
5. **Update BookingForm** - Thêm validation cho form booking

---

## 🎯 Best Practices

1. **Always validate on blur** - Không làm phiền user khi đang gõ
2. **Show errors clearly** - Dùng màu đỏ + icon + message rõ ràng
3. **Validate before submit** - Call `validateAll()` trước khi gửi form
4. **Clear errors on change** - Xóa lỗi khi user bắt đầu sửa
5. **Use consistent messages** - Dùng message tiếng Việt thống nhất

---

## 🔍 Debug Tips

```javascript
// Log validation errors
console.log('Errors:', errors);
console.log('Has errors:', hasErrors(errors));
console.log('First error:', getFirstError(errors));

// Check form state
console.log('Values:', values);
console.log('Is valid:', isValid);
console.log('Is dirty:', isDirty);
```

---

## 📞 Need Help?

- Check `src/utils/validation.js` for all available validators
- Check `src/hooks/useFormValidation.js` for hook API
- Check `src/components/common/FormInput.jsx` for component props
- See `AdminCreateUserPage.jsx` for complete example
