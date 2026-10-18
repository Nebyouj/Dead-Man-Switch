import { useEffect, useState } from 'react';
import { api } from '../api/client';
import { useAuth } from '../auth/AuthContext';
import { AdminLayout } from '../components/AdminLayout';

export function AdminCheckInsPage() {
  const { token } = useAuth();
  const [checkIns, setCheckIns] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const fetchCheckIns = () => {
    setLoading(true);
    api.adminListCheckIns(token)
      .then(setCheckIns)
      .catch((err) => setError(err.message))
      .finally(() => setLoading(false));
  };

  useEffect(() => {
    fetchCheckIns();
  }, [token]);

  const handleCancel = async (id) => {
    if (!window.confirm("Force cancel this check-in?")) return;
    try {
      await api.adminCancelCheckIn(token, id);
      fetchCheckIns();
    } catch (err) {
      alert("Error canceling check-in: " + err.message);
    }
  };

  return (
    <AdminLayout>
      <h2>Manage Check-ins</h2>
      {error && <p className="form-error">{error}</p>}
      
      {loading ? <p>Loading check-ins...</p> : (
        <table style={{ width: '100%', textAlign: 'left', borderCollapse: 'collapse', marginTop: '1rem' }}>
          <thead>
            <tr style={{ borderBottom: '2px solid #ccc' }}>
              <th style={{ padding: '0.5rem' }}>ID</th>
              <th style={{ padding: '0.5rem' }}>User Email</th>
              <th style={{ padding: '0.5rem' }}>Status</th>
              <th style={{ padding: '0.5rem' }}>Deadline</th>
              <th style={{ padding: '0.5rem' }}>Actions</th>
            </tr>
          </thead>
          <tbody>
            {checkIns.map(c => (
              <tr key={c.id} style={{ borderBottom: '1px solid #eee' }}>
                <td style={{ padding: '0.5rem' }}>{c.id}</td>
                <td style={{ padding: '0.5rem' }}>{c.user_email}</td>
                <td style={{ padding: '0.5rem' }}>
                  <span className="status-badge">{c.status}</span>
                </td>
                <td style={{ padding: '0.5rem' }}>{new Date(c.deadline).toLocaleString()}</td>
                <td style={{ padding: '0.5rem' }}>
                  {c.status === 'ACTIVE' && (
                    <button 
                      className="link-button danger" 
                      onClick={() => handleCancel(c.id)}
                    >
                      Cancel
                    </button>
                  )}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </AdminLayout>
  );
}
