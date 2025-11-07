import { useEffect, useState } from 'react'
import { useNavigate, useParams } from 'react-router-dom'
import http from '../../api/http'

export default function BranchEdit() {
  const { id } = useParams()
  const navigate = useNavigate()
  const [users, setUsers] = useState([])
  const [form, setForm] = useState({ branchName:'', location:'', managerId:'', status:'ACTIVE' })
  const [loading, setLoading] = useState(true)

  useEffect(() => { (async () => {
    const [b, u] = await Promise.all([http.get(`/branches/${id}`), http.get('/users')])
    const d = b.data.data || b.data
    setForm({ branchName: d.branchName, location: d.location, managerId: d.managerId || '', status: d.status || 'ACTIVE' })
    setUsers(u.data.data || u.data)
    setLoading(false)
  })() }, [id])

  const submit = async (e) => {
    e.preventDefault()
    await http.put(`/branches/${id}`, { ...form, managerId: form.managerId ? Number(form.managerId) : null })
    alert('Đã cập nhật chi nhánh')
    navigate('/branches')
  }

  const del = async () => {
    if (!confirm('Vô hiệu hoá chi nhánh này?')) return
    await http.delete(`/branches/${id}`)
    navigate('/branches')
  }

  const set = (k) => (e) => setForm(s => ({ ...s, [k]: e.target.value }))

  if (loading) return <div>Đang tải...</div>

  return (
    <div>
      <h3>Chỉnh sửa chi nhánh</h3>
      <form onSubmit={submit} style={{ background: 'white', padding: 16, borderRadius: 8, maxWidth: 640 }}>
        <label>Tên chi nhánh</label>
        <input value={form.branchName} onChange={set('branchName')} />
        <label>Địa chỉ</label>
        <input value={form.location} onChange={set('location')} />
        <label>Quản lý</label>
        <select value={form.managerId} onChange={set('managerId')}>
          <option value=''>Chọn quản lý</option>
          {users?.map(u => <option key={u.id} value={u.id}>{u.fullName}</option>)}
        </select>
        <label>Trạng thái</label>
        <select value={form.status} onChange={set('status')}>
          {['ACTIVE','INACTIVE'].map(s=> <option key={s} value={s}>{s}</option>)}
        </select>
        <div style={{ marginTop: 12, display: 'flex', gap: 8 }}>
          <button type='submit'>Lưu</button>
          <button type='button' onClick={del}>Xoá/Vô hiệu hoá</button>
        </div>
      </form>
    </div>
  )
}

