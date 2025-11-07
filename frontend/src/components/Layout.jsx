import { NavLink, Outlet, useNavigate } from 'react-router-dom'
import { getAuth, clearAuth } from '../utils/auth'
import http from '../api/http'

export default function Layout() {
  const navigate = useNavigate()
  const auth = getAuth()

  const logout = async () => {
    try { await http.post('/auth/logout') } catch {}
    clearAuth()
    navigate('/login', { replace: true })
  }

  return (
    <div style={{ display: 'flex', minHeight: '100vh', background: '#f5f7fb' }}>
      <aside style={{ width: 240, background: '#0c4a6e', color: 'white', padding: 16 }}>
        <div style={{ fontWeight: 700, marginBottom: 24 }}>TranspoManager</div>
        <nav style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
          <NavLink to="/admin" style={linkStyle}>Tổng quan</NavLink>
          <div style={{ marginTop: 8, opacity: .7 }}>Quản trị hệ thống</div>
          <NavLink to="/users" style={linkStyle}>Danh sách người dùng</NavLink>
          <NavLink to="/branches" style={linkStyle}>Danh sách chi nhánh</NavLink>
          <NavLink to="/settings" style={linkStyle}>Cấu hình hệ thống</NavLink>
        </nav>
      </aside>
      <main style={{ flex: 1, display: 'flex', flexDirection: 'column' }}>
        <header style={{ background: 'white', padding: '12px 16px', borderBottom: '1px solid #e5e7eb', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <input placeholder="Tìm nhanh..." style={{ padding: 8, width: 360, border: '1px solid #d1d5db', borderRadius: 8 }} />
          <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
            <div style={{ textAlign: 'right' }}>
              <div style={{ fontWeight: 600 }}>{auth?.username || 'User'}</div>
              <div style={{ fontSize: 12, color: '#6b7280' }}>{auth?.roleName || ''}</div>
            </div>
            <button onClick={logout} style={{ padding: '6px 12px' }}>Đăng xuất</button>
          </div>
        </header>
        <div style={{ padding: 16 }}>
          <Outlet />
        </div>
      </main>
    </div>
  )
}

const linkStyle = ({ isActive }) => ({
  color: 'white',
  textDecoration: 'none',
  padding: '8px 10px',
  borderRadius: 8,
  background: isActive ? 'rgba(255,255,255,0.15)' : 'transparent'
})

