import { useEffect, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import http from '../../api/http'

export default function BranchCreate() {
  const navigate = useNavigate()
  const [users, setUsers] = useState([])
  const [form, setForm] = useState({ branchName:'', location:'', phone:'', managerId:'' })

  useEffect(() => { (async () => {
    // lấy tất cả user (admin sẽ có quyền)
    const res = await http.get('/users')
    setUsers(res.data.data || res.data)
  })() }, [])

  const submit = async (e) => {
    e.preventDefault()
    await http.post('/branches', { ...form, managerId: form.managerId ? Number(form.managerId) : null })
    alert('Đã tạo chi nhánh')
    navigate('/branches')
  }

  const set = (k) => (e) => setForm(s => ({ ...s, [k]: e.target.value }))

  return (
    <div>
      <h3>Tạo chi nhánh</h3>
      <form onSubmit={submit} style={{ background: 'white', padding: 16, borderRadius: 8, maxWidth: 640 }}>
        <label>Tên chi nhánh</label>
        <input value={form.branchName} onChange={set('branchName')} required />
        <label>Địa chỉ</label>
        <input value={form.location} onChange={set('location')} required />
        <label>SĐT</label>
        <input value={form.phone} onChange={set('phone')} />
        <label>Quản lý chi nhánh</label>
        <select value={form.managerId} onChange={set('managerId')}>
          <option value=''>Chọn quản lý</option>
          {users?.map(u => <option key={u.id} value={u.id}>{u.fullName}</option>)}
        </select>
        <div style={{ marginTop: 12 }}>
          <button type='submit'>Lưu</button>
        </div>
      </form>
    </div>
  )
}

