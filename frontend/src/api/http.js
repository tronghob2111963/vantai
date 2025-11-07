import axios from 'axios'
import Cookies from 'js-cookie'

const http = axios.create({
  baseURL: '/api'
})

http.interceptors.request.use((config) => {
  try {
    const raw = Cookies.get('tokenResponse')
    if (raw) {
      const tr = JSON.parse(raw)
      if (tr?.AccessToken) {
        config.headers.Authorization = `Bearer ${tr.AccessToken}`
      }
    }
  } catch {}
  return config
})

// If token is invalid/expired, clean up and send user to login
http.interceptors.response.use(
  (res) => res,
  (error) => {
    const status = error?.response?.status
    if (status === 401 || status === 403) {
      try { Cookies.remove('tokenResponse') } catch {}
      if (typeof window !== 'undefined') {
        window.location.replace('/login')
      }
    }
    return Promise.reject(error)
  }
)

export default http
