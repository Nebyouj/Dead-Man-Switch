import { Link } from 'react-router-dom';
import { useAuth } from '../auth/AuthContext';

export function AdminLayout({ children }) {
  const { logout } = useAuth();

  return (
    <div className="page dashboard">
      <header className="dashboard-header">
        <h1>Admin Dashboard</h1>
        <div style={{ display: 'flex', gap: '1rem', alignItems: 'baseline' }}>
          <Link to="/dashboard">Back to App</Link>
          <button className="link-button" onClick={logout}>
            Log out
          </button>
        </div>
      </header>
      
      <nav style={{ marginBottom: '2rem', display: 'flex', gap: '1rem', borderBottom: '1px solid #ccc', paddingBottom: '1rem' }}>
        <Link to="/admin">Stats Overview</Link>
        <Link to="/admin/users">Manage Users</Link>
        <Link to="/admin/checkins">Manage Check-ins</Link>
      </nav>

      <main>
        {children}
      </main>
    </div>
  );
}
