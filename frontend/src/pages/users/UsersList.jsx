import { useEffect, useMemo, useState } from 'react'
import { Link } from 'react-router-dom'
import http from '../../api/http'

export default function UsersList() {
  const [items, setItems] = useState([])
  const [roles, setRoles] = useState([])
  const [loading, setLoading] = useState(true)
  const [keyword, setKeyword] = useState('')
  const [roleId, setRoleId] = useState('')
  const [status, setStatus] = useState('')

  const load = async () => {
    setLoading(true)
    const params = {}
    if (keyword) params.keyword = keyword
    if (roleId) params.roleId = roleId
    if (status) params.status = status
    const [u, r] = await Promise.all([
      http.get('/users', { params }),
      http.get('/roles')
    ])
    setItems(u.data.data || u.data)
    setRoles(r.data)
    setLoading(false)
  }

  useEffect(() => { load() }, [])

  const statuses = useMemo(() => ['ACTIVE','INACTIVE','PENDING'], [])

  return (
    <div>
      <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 12 }}>
        <h3>Danh sách người dùng</h3>
        <Link to="/users/create"><button>Tạo mới người dùng</button></Link>
      </div>
      <div style={{ display: 'flex', gap: 8, marginBottom: 12 }}>
        <input placeholder="Tìm theo tên/email" value={keyword} onChange={e=>setKeyword(e.target.value)} />
        <select value={roleId} onChange={e=>setRoleId(e.target.value)}>
          <option value="">Tất cả vai trò</option>
          {roles?.map(r=> <option key={r.id} value={r.id}>{r.roleName || r.name}</option>)}
        </select>
        <select value={status} onChange={e=>setStatus(e.target.value)}>
          <option value="">Tất cả trạng thái</option>
          {statuses.map(s=> <option key={s} value={s}>{s}</option>)}
        </select>
        <button onClick={load}>Lọc</button>
      </div>

      {loading ? <div>Đang tải...</div> : (
        <table width="100%" cellPadding="8" style={{ background: 'white', borderCollapse: 'collapse' }}>
          <thead>
            <tr style={{ background: '#f3f4f6' }}>
              <th align="left">Họ tên</th>
              <th align="left">Email</th>
              <th align="left">SĐT</th>
              <th align="left">Vai trò</th>
              <th align="left">Trạng thái</th>
              <th align="left">Hành động</th>
            </tr>
          </thead>
          <tbody>
            {items?.map(u => (
              <tr key={u.id} style={{ borderTop: '1px solid #e5e7eb' }}>
                <td>{u.fullName}</td>
                <td>{u.email}</td>
                <td>{u.phone}</td>
                <td>{u.roleName}</td>
                <td>{u.status}</td>
                <td>
                  <Link to={`/users/${u.id}`}><button>Sửa</button></Link>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </div>
  )
}

