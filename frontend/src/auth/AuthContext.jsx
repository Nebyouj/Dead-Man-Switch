import { createContext, useCallback, useContext, useEffect, useState } from 'react';
import { api } from '../api/client';

const AuthContext = createContext(null);
const STORAGE_KEY = 'dms_access_token';

/**
 * The JWT is stored in localStorage so a page refresh doesn't log the user
 * out. That's a deliberate simplification for this phase, not a final
 * security decision — localStorage is readable by any script on the page,
 * so if this app ever handles something more sensitive than check-in
 * timers, swap this for an httpOnly cookie issued by the backend instead.
 */
export function AuthProvider({ children }) {
  const [token, setToken] = useState(() => localStorage.getItem(STORAGE_KEY));
  const [user, setUser] = useState(null);

  useEffect(() => {
    if (token) {
      localStorage.setItem(STORAGE_KEY, token);
      api.getMe(token).then(setUser).catch(() => {
        setToken(null);
        setUser(null);
      });
    } else {
      localStorage.removeItem(STORAGE_KEY);
      setUser(null);
    }
  }, [token]);

  const login = useCallback(async (email, password) => {
    const { access_token } = await api.login(email, password);
    setToken(access_token);
  }, []);

  const loginWithGoogle = useCallback(async (idToken) => {
    const { access_token } = await api.googleLogin(idToken);
    setToken(access_token);
  }, []);

  const register = useCallback(async (email, password) => {
    await api.register(email, password);
    // Registration doesn't return a token — log in right after so the
    // person isn't asked to type their password twice in a row.
    await login(email, password);
  }, [login]);

  const logout = useCallback(() => {
    setToken(null);
    setUser(null);
  }, []);

  const value = { token, user, isAuthenticated: Boolean(token), login, loginWithGoogle, register, logout };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error('useAuth must be used within an AuthProvider');
  return ctx;
}
