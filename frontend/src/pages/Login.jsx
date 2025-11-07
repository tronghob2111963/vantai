import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import http from '../api/http'
import { saveTokenResponse } from '../utils/auth'

export default function Login() {
  const [username, setUsername] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)
  const navigate = useNavigate()

  const submit = async (e) => {
    e.preventDefault()
    setError('')
    setLoading(true)
    try {
      const res = await http.post('/auth/login', { username, password })
      saveTokenResponse(res.data)
      navigate('/admin', { replace: true })
    } catch (err) {
      setError(err?.response?.data?.message || 'Đăng nhập thất bại')
    } finally { setLoading(false) }
  }

  return (
    <div style={{ display: 'grid', placeItems: 'center', height: '100vh', background: '#f3f4f6' }}>
      <form onSubmit={submit} style={{ background: 'white', padding: 24, borderRadius: 12, width: 360, boxShadow: '0 2px 16px rgba(0,0,0,.06)' }}>
        <h2 style={{ marginTop: 0 }}>Đăng nhập</h2>
        <label>Email/Username</label>
        <input value={username} onChange={e=>setUsername(e.target.value)} required style={inputStyle} />
        <label>Mật khẩu</label>
        <input type="password" value={password} onChange={e=>setPassword(e.target.value)} required style={inputStyle} />
        {error && <div style={{ color: 'red', marginTop: 8 }}>{error}</div>}
        <button type="submit" disabled={loading} style={{ marginTop: 12, width: '100%', padding: '10px 12px' }}>
          {loading ? 'Đang đăng nhập...' : 'Đăng nhập'}
        </button>
      </form>
    </div>
  )
}

const inputStyle = { width: '100%', padding: 10, margin: '6px 0 10px', border: '1px solid #d1d5db', borderRadius: 8 }

