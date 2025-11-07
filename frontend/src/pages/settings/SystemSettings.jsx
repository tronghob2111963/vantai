import { useEffect, useState } from 'react'
import http from '../../api/http'

export default function SystemSettings() {
  const [items, setItems] = useState([])
  const [key, setKey] = useState('')
  const [value, setValue] = useState('')
  const [description, setDescription] = useState('')

  const load = async () => {
    const res = await http.get('/system-settings')
    setItems(res.data)
  }

  const create = async (e) => {
    e.preventDefault()
    await http.post('/system-settings', { key, value, description })
    setKey(''); setValue(''); setDescription('')
    await load()
  }

  const update = async (id, v) => {
    await http.put(`/system-settings/${id}`, v)
    await load()
  }

  const remove = async (id) => {
    if (!confirm('Xoá cấu hình?')) return
    await http.delete(`/system-settings/${id}`)
    await load()
  }

  useEffect(() => { load() }, [])

  return (
    <div>
      <h3>Cấu hình hệ thống</h3>
      <form onSubmit={create} style={{ background: 'white', padding: 12, borderRadius: 8, marginBottom: 12 }}>
        <input placeholder='Key' value={key} onChange={e=>setKey(e.target.value)} required />
        <input placeholder='Value' value={value} onChange={e=>setValue(e.target.value)} required />
        <input placeholder='Mô tả' value={description} onChange={e=>setDescription(e.target.value)} />
        <button type='submit'>Thêm</button>
      </form>
      <table width='100%' cellPadding='8' style={{ background: 'white', borderCollapse: 'collapse' }}>
        <thead>
          <tr style={{ background: '#f3f4f6' }}>
            <th align='left'>Key</th>
            <th align='left'>Value</th>
            <th align='left'>Mô tả</th>
            <th align='left'>Hành động</th>
          </tr>
        </thead>
        <tbody>
          {items.map(s => (
            <tr key={s.id} style={{ borderTop: '1px solid #e5e7eb' }}>
              <td>{s.key}</td>
              <td>{s.value}</td>
              <td>{s.description}</td>
              <td>
                <button onClick={() => update(s.id, { key: s.key, value: prompt('Value mới', s.value) ?? s.value, description: s.description })}>Sửa</button>
                <button onClick={() => remove(s.id)} style={{ marginLeft: 6 }}>Xoá</button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  )
}

