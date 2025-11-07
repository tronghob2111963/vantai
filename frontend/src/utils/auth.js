import Cookies from 'js-cookie'

export const saveTokenResponse = (tokenResponse) => {
  Cookies.set('tokenResponse', JSON.stringify(tokenResponse), { expires: 7 })
}

export const getAuth = () => {
  const raw = Cookies.get('tokenResponse')
  if (!raw) return null
  try {
    return JSON.parse(raw)
  } catch {
    return null
  }
}

export const clearAuth = () => {
  Cookies.remove('tokenResponse')
}

