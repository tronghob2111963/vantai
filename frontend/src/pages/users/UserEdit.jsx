import { useEffect, useState } from 'react'
import { useNavigate, useParams } from 'react-router-dom'
import http from '../../api/http'

export default function UserEdit() {
  const { id } = useParams()
  const navigate = useNavigate()
  const [roles, setRoles] = useState([])
  const [form, setForm] = useState({ fullName:'', email:'', phone:'', address:'', roleId:'', status:'' })
  const [loading, setLoading] = useState(true)

  useEffect(() => { (async () => {
    const [u, r] = await Promise.all([http.get(`/users/${id}`), http.get('/roles')])
    const d = u.data.data || u.data
    setForm({
      fullName: d.fullName || '',
      email: d.email || '',
      phone: d.phone || '',
      address: d.address || '',
      roleId: d.roleId || '',
      status: d.status || 'ACTIVE'
    })
    setRoles(r.data)
    setLoading(false)
  })() }, [id])

  const submit = async (e) => {
    e.preventDefault()
    await http.put(`/users/${id}`, { ...form, roleId: form.roleId ? Number(form.roleId) : null })
    alert('Cập nhật thành công')
    navigate('/users')
  }

  const toggle = async () => {
    await http.patch(`/users/${id}/toggle-status`)
    alert('Đã đổi trạng thái')
  }

  const set = (k) => (e) => setForm(s => ({ ...s, [k]: e.target.value }))

  if (loading) return <div>Đang tải...</div>

  return (
    <div>
      <h3>Chỉnh sửa người dùng</h3>
      <form onSubmit={submit} style={{ background: 'white', padding: 16, borderRadius: 8, maxWidth: 640 }}>
        <label>Họ tên</label>
        <input value={form.fullName} onChange={set('fullName')} />
        <label>Email</label>
        <input value={form.email} onChange={set('email')} />
        <label>SĐT</label>
        <input value={form.phone} onChange={set('phone')} />
        <label>Địa chỉ</label>
        <input value={form.address} onChange={set('address')} />
        <label>Vai trò</label>
        <select value={form.roleId} onChange={set('roleId')}>
          <option value=''>Chọn vai trò</option>
          {roles.map(r=> <option key={r.id} value={r.id}>{r.roleName || r.name}</option>)}
        </select>
        <label>Trạng thái</label>
        <select value={form.status} onChange={set('status')}>
          {['ACTIVE','INACTIVE','PENDING'].map(s=> <option key={s} value={s}>{s}</option>)}
        </select>
        <div style={{ marginTop: 12, display: 'flex', gap: 8 }}>
          <button type='submit'>Lưu</button>
          <button type='button' onClick={toggle}>Kích hoạt/Vô hiệu hoá</button>
        </div>
      </form>
    </div>
  )
}

