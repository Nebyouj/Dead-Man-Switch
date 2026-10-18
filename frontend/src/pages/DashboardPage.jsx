import { useCallback, useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { api } from '../api/client';
import { useAuth } from '../auth/AuthContext';
import { CheckInForm } from '../components/CheckInForm';
import { CheckInList } from '../components/CheckInList';

export function DashboardPage() {
  const { token, user, logout } = useAuth();
  const [checkIns, setCheckIns] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const refresh = useCallback(async () => {
    setError(null);
    try {
      const data = await api.listCheckIns(token);
      setCheckIns(data);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }, [token]);

  useEffect(() => {
    refresh();
  }, [refresh]);

  async function handleCreate(payload) {
    await api.createCheckIn(token, payload);
    await refresh();
  }

  async function handleCheckIn(id) {
    await api.checkIn(token, id);
    await refresh();
  }

  async function handleCancel(id) {
    await api.cancelCheckIn(token, id);
    await refresh();
  }

  async function handleDelete(id) {
    await api.deleteCheckIn(token, id);
    await refresh();
  }

  async function handleTrigger(id) {
    await api.triggerCheckIn(token, id);
    await refresh();
  }

  return (
    <div className="page dashboard">
      <header className="dashboard-header">
        <h1>Dead Man's Switch</h1>
        <div style={{ display: 'flex', gap: '1rem', alignItems: 'baseline' }}>
          {user?.role === 'ADMIN' && (
            <Link to="/admin" className="link-button" style={{ fontWeight: 'bold' }}>
              Admin Panel
            </Link>
          )}
          <button className="link-button" onClick={logout}>
            Log out
          </button>
        </div>
      </header>

      <CheckInForm onCreate={handleCreate} />

      <section>
        <h2>Your check-ins</h2>
        {loading && <p>Loading…</p>}
        {error && <p className="form-error">{error}</p>}
        {!loading && !error && (
          <CheckInList
            checkIns={checkIns}
            onCheckIn={handleCheckIn}
            onCancel={handleCancel}
            onDelete={handleDelete}
            onTrigger={handleTrigger}
          />
        )}
      </section>
    </div>
  );
}
