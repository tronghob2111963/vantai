import { useEffect, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import http from '../../api/http'

export default function UserCreate() {
  const [roles, setRoles] = useState([])
  const [form, setForm] = useState({ fullName: '', username: '', email: '', phone: '', address: '', roleId: '' })
  const [saving, setSaving] = useState(false)
  const navigate = useNavigate()

  useEffect(() => { (async () => { const r = await http.get('/roles'); setRoles(r.data) })() }, [])

  const submit = async (e) => {
    e.preventDefault()
    setSaving(true)
    try {
      await http.post('/users/register', { ...form, roleId: form.roleId ? Number(form.roleId) : null })
      alert('Tạo người dùng thành công. Hệ thống sẽ gửi liên kết xác thực qua email (khi BE bật).')
      navigate('/users')
    } catch (e) { alert('Tạo thất bại') } finally { setSaving(false) }
  }

  const set = (k) => (e) => setForm(s => ({ ...s, [k]: e.target.value }))

  return (
    <div>
      <h3>Tạo người dùng</h3>
      <form onSubmit={submit} style={{ background: 'white', padding: 16, borderRadius: 8, maxWidth: 640 }}>
        <div className='grid'>
          <label>Họ tên</label>
          <input value={form.fullName} onChange={set('fullName')} required />
          <label>Username</label>
          <input value={form.username} onChange={set('username')} required />
          <label>Email</label>
          <input value={form.email} onChange={set('email')} />
          <label>SĐT</label>
          <input value={form.phone} onChange={set('phone')} required />
          <label>Địa chỉ</label>
          <input value={form.address} onChange={set('address')} required />
          <label>Vai trò</label>
          <select value={form.roleId} onChange={set('roleId')}>
            <option value=''>Chọn vai trò</option>
            {roles.map(r=> <option key={r.id} value={r.id}>{r.roleName || r.name}</option>)}
          </select>
        </div>
        <div style={{ marginTop: 12 }}>
          <button disabled={saving} type='submit'>Lưu</button>
        </div>
      </form>
    </div>
  )
}

