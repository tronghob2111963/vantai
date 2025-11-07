import { Routes, Route, Navigate } from 'react-router-dom'
import Login from './pages/Login'
import Dashboard from './pages/Dashboard'
import UsersList from './pages/users/UsersList'
import UserCreate from './pages/users/UserCreate'
import UserEdit from './pages/users/UserEdit'
import BranchesList from './pages/branches/BranchesList'
import BranchCreate from './pages/branches/BranchCreate'
import BranchEdit from './pages/branches/BranchEdit'
import SystemSettings from './pages/settings/SystemSettings'
import Layout from './components/Layout'
import { getAuth } from './utils/auth'

const PrivateRoute = ({ children }) => {
  const auth = getAuth()
  return auth?.AccessToken ? children : <Navigate to="/login" replace />
}

export default function App() {
  return (
    <Routes>
      <Route path="/login" element={<Login />} />
      <Route
        path="/"
        element={
          <PrivateRoute>
            <Layout />
          </PrivateRoute>
        }
      >
        <Route index element={<Navigate to="/admin" replace />} />
        <Route path="admin" element={<Dashboard />} />
        <Route path="users" element={<UsersList />} />
        <Route path="users/create" element={<UserCreate />} />
        <Route path="users/:id" element={<UserEdit />} />
        <Route path="branches" element={<BranchesList />} />
        <Route path="branches/create" element={<BranchCreate />} />
        <Route path="branches/:id" element={<BranchEdit />} />
        <Route path="settings" element={<SystemSettings />} />
      </Route>
      <Route path="*" element={<Navigate to="/login" replace />} />
    </Routes>
  )
}

