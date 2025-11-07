import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import http from '../../api/http'

export default function BranchesList() {
  const [items, setItems] = useState([])
  const [keyword, setKeyword] = useState('')
  const [loading, setLoading] = useState(true)

  const load = async () => {
    setLoading(true)
    const res = await http.get('/branches', { params: { keyword } })
    setItems(res.data.data?.content || res.data.data || res.data)
    setLoading(false)
  }

  useEffect(() => { load() }, [])

  return (
    <div>
      <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 12 }}>
        <h3>Danh sách chi nhánh</h3>
        <Link to="/branches/create"><button>Tạo chi nhánh mới</button></Link>
      </div>
      <div style={{ display: 'flex', gap: 8, marginBottom: 12 }}>
        <input placeholder="Tìm theo tên/địa chỉ" value={keyword} onChange={e=>setKeyword(e.target.value)} />
        <button onClick={load}>Lọc</button>
      </div>
      {loading ? <div>Đang tải...</div> : (
        <table width="100%" cellPadding="8" style={{ background: 'white', borderCollapse: 'collapse' }}>
          <thead>
            <tr style={{ background: '#f3f4f6' }}>
              <th align="left">Tên chi nhánh</th>
              <th align="left">Địa chỉ</th>
              <th align="left">Quản lý</th>
              <th align="left">Trạng thái</th>
              <th align="left">Hành động</th>
            </tr>
          </thead>
          <tbody>
            {items?.map(b => (
              <tr key={b.id} style={{ borderTop: '1px solid #e5e7eb' }}>
                <td>{b.branchName}</td>
                <td>{b.location}</td>
                <td>{b.manager}</td>
                <td>{b.status}</td>
                <td>
                  <Link to={`/branches/${b.id}`}><button>Sửa</button></Link>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </div>
  )
}

