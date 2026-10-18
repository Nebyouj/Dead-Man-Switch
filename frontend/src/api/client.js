const BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:8000';

export class ApiError extends Error {
  constructor(message, status, detail) {
    super(message);
    this.name = 'ApiError';
    this.status = status;
    this.detail = detail;
  }
}

/**
 * Low-level request helper. Handles JSON (de)serialization, attaches the
 * bearer token when one is provided, and normalizes FastAPI's error shape
 * (`{"detail": "..."}` or a Pydantic validation array) into a readable
 * message so callers don't each have to unpack it themselves.
 */
async function request(path, { method = 'GET', body, token, form } = {}) {
  const headers = {};
  if (token) headers.Authorization = `Bearer ${token}`;

  let requestBody;
  if (form) {
    headers['Content-Type'] = 'application/x-www-form-urlencoded';
    requestBody = new URLSearchParams(form).toString();
  } else if (body !== undefined) {
    headers['Content-Type'] = 'application/json';
    requestBody = JSON.stringify(body);
  }

  let response;
  try {
    response = await fetch(`${BASE_URL}${path}`, { method, headers, body: requestBody });
  } catch (networkError) {
    throw new ApiError(
      `Couldn't reach the API at ${BASE_URL}. Is the backend running?`,
      0,
      networkError.message
    );
  }

  if (response.status === 204) return null;

  const text = await response.text();
  const data = text ? JSON.parse(text) : null;

  if (!response.ok) {
    const detail = data?.detail;
    const message = Array.isArray(detail)
      ? detail.map((d) => d.msg).join('; ')
      : detail || `Request failed (${response.status})`;
    throw new ApiError(message, response.status, detail);
  }

  return data;
}

export const api = {
  register: (email, password) => request('/auth/register', { method: 'POST', body: { email, password } }),

  login: (email, password) =>
    request('/auth/login', { method: 'POST', form: { username: email, password } }),

  googleLogin: (idToken) => request('/auth/google', { method: 'POST', body: { id_token: idToken } }),

  getMe: (token) => request('/auth/me', { token }),

  listCheckIns: (token) => request('/checkins', { token }),

  createCheckIn: (token, payload) => request('/checkins', { method: 'POST', body: payload, token }),

  checkIn: (token, id) => request(`/checkins/${id}/check-in`, { method: 'POST', token }),

  cancelCheckIn: (token, id) => request(`/checkins/${id}/cancel`, { method: 'POST', token }),

  deleteCheckIn: (token, id) => request(`/checkins/${id}`, { method: 'DELETE', token }),

  triggerCheckIn: (token, id) => request(`/checkins/${id}/trigger`, { method: 'POST', token }),

  adminGetStats: (token) => request('/admin/stats', { token }),

  adminListUsers: (token) => request('/admin/users', { token }),

  adminDeleteUser: (token, id) => request(`/admin/users/${id}`, { method: 'DELETE', token }),

  adminUpdateUserRole: (token, id, role) => request(`/admin/users/${id}/role`, { method: 'PUT', body: { role }, token }),

  adminListCheckIns: (token) => request('/admin/checkins', { token }),

  adminCancelCheckIn: (token, id) => request(`/admin/checkins/${id}/cancel`, { method: 'POST', token }),
};
