import { useEffect, useState } from 'react';
import { api } from '../api/client';
import { useAuth } from '../auth/AuthContext';
import { AdminLayout } from '../components/AdminLayout';

export function AdminDashboardPage() {
  const { token } = useAuth();
  const [stats, setStats] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    api.adminGetStats(token)
      .then(setStats)
      .catch((err) => setError(err.message))
      .finally(() => setLoading(false));
  }, [token]);

  return (
    <AdminLayout>
      <h2>System Overview</h2>
      {loading && <p>Loading stats...</p>}
      {error && <p className="form-error">{error}</p>}
      {stats && (
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(150px, 1fr))', gap: '1rem' }}>
          <div className="checkin-card">
            <h3>Total Users</h3>
            <p style={{ fontSize: '2rem', margin: '0.5rem 0' }}>{stats.total_users}</p>
          </div>
          <div className="checkin-card status-active">
            <h3>Active Check-ins</h3>
            <p style={{ fontSize: '2rem', margin: '0.5rem 0' }}>{stats.total_active_checkins}</p>
          </div>
          <div className="checkin-card status-triggered">
            <h3>Triggered Check-ins</h3>
            <p style={{ fontSize: '2rem', margin: '0.5rem 0' }}>{stats.total_triggered_checkins}</p>
          </div>
        </div>
      )}
    </AdminLayout>
  );
}
