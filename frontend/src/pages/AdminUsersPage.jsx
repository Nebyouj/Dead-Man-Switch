import { useEffect, useState } from 'react';
import { api } from '../api/client';
import { useAuth } from '../auth/AuthContext';
import { AdminLayout } from '../components/AdminLayout';

export function AdminUsersPage() {
  const { token, user: currentUser } = useAuth();
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const fetchUsers = () => {
    setLoading(true);
    api.adminListUsers(token)
      .then(setUsers)
      .catch((err) => setError(err.message))
      .finally(() => setLoading(false));
  };

  useEffect(() => {
    fetchUsers();
  }, [token]);

  const handleDelete = async (id) => {
    if (!window.confirm("Are you sure you want to hard-delete this user and all their check-ins?")) return;
    try {
      await api.adminDeleteUser(token, id);
      fetchUsers();
    } catch (err) {
      alert("Error deleting user: " + err.message);
    }
  };

  const handleToggleRole = async (id, currentRole) => {
    const newRole = currentRole === 'ADMIN' ? 'USER' : 'ADMIN';
    if (!window.confirm(`Are you sure you want to change this user's role to ${newRole}?`)) return;
    try {
      await api.adminUpdateUserRole(token, id, newRole);
      fetchUsers();
    } catch (err) {
      alert("Error updating role: " + err.message);
    }
  };

  return (
    <AdminLayout>
      <h2>Manage Users</h2>
      {error && <p className="form-error">{error}</p>}
      
      {loading ? <p>Loading users...</p> : (
        <table style={{ width: '100%', textAlign: 'left', borderCollapse: 'collapse', marginTop: '1rem' }}>
          <thead>
            <tr style={{ borderBottom: '2px solid #ccc' }}>
              <th style={{ padding: '0.5rem' }}>ID</th>
              <th style={{ padding: '0.5rem' }}>Email</th>
              <th style={{ padding: '0.5rem' }}>Role</th>
              <th style={{ padding: '0.5rem' }}>Actions</th>
            </tr>
          </thead>
          <tbody>
            {users.map(u => (
              <tr key={u.id} style={{ borderBottom: '1px solid #eee' }}>
                <td style={{ padding: '0.5rem' }}>{u.id}</td>
                <td style={{ padding: '0.5rem' }}>{u.email}</td>
                <td style={{ padding: '0.5rem' }}>
                  <span className="status-badge" style={{ background: u.role === 'ADMIN' ? '#1a56db' : '#ccc', color: u.role === 'ADMIN' ? 'white' : 'black', padding: '0.2rem 0.5rem', borderRadius: '4px' }}>
                    {u.role}
                  </span>
                </td>
                <td style={{ padding: '0.5rem', display: 'flex', gap: '0.5rem' }}>
                  <button 
                    className="link-button" 
                    onClick={() => handleToggleRole(u.id, u.role)}
                    disabled={u.id === currentUser.id}
                  >
                    {u.role === 'ADMIN' ? 'Demote' : 'Make Admin'}
                  </button>
                  <button 
                    className="link-button danger" 
                    onClick={() => handleDelete(u.id)}
                    disabled={u.id === currentUser.id}
                  >
                    Delete
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </AdminLayout>
  );
}
