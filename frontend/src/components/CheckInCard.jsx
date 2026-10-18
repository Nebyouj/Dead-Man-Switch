import { useState } from 'react';

const STATUS_LABEL = {
  ACTIVE: 'Active',
  TRIGGERED: 'Triggered',
  CANCELLED: 'Cancelled',
};

function formatDeadline(iso) {
  // The API returns naive UTC timestamps (no "Z" suffix) — without adding
  // one back, the browser would parse it as local time and show the wrong
  // hour for anyone not in UTC.
  return new Date(`${iso}Z`).toLocaleString();
}

export function CheckInCard({ checkIn, onCheckIn, onCancel, onDelete, onTrigger }) {
  const [pendingAction, setPendingAction] = useState(null);
  const [error, setError] = useState(null);

  async function run(actionName, fn) {
    setError(null);
    setPendingAction(actionName);
    try {
      await fn(checkIn.id);
    } catch (err) {
      setError(err.message);
    } finally {
      setPendingAction(null);
    }
  }

  const isActive = checkIn.status === 'ACTIVE';
  const busy = pendingAction !== null;

  return (
    <li className={`checkin-card status-${checkIn.status.toLowerCase()}`}>
      <div className="checkin-card-header">
        <h3>{checkIn.name}</h3>
        <span className="status-badge">{STATUS_LABEL[checkIn.status]}</span>
      </div>

      {checkIn.message && <p className="checkin-message">{checkIn.message}</p>}

      <dl className="checkin-meta">
        <div>
          <dt>Deadline</dt>
          <dd>{formatDeadline(checkIn.deadline)}</dd>
        </div>
        <div>
          <dt>Channels</dt>
          <dd>{checkIn.channels.join(', ')}</dd>
        </div>
      </dl>

      {error && <p className="form-error">{error}</p>}

      <div className="checkin-actions">
        {isActive && (
          <>
            <button onClick={() => run('checkin', onCheckIn)} disabled={busy}>
              {pendingAction === 'checkin' ? 'Checking in…' : "I'm okay — check in"}
            </button>
            <button className="link-button" onClick={() => run('cancel', onCancel)} disabled={busy}>
              {pendingAction === 'cancel' ? 'Cancelling…' : 'Cancel'}
            </button>
            <button
              className="link-button"
              onClick={() => run('trigger', onTrigger)}
              disabled={busy}
              title="Dev-only: fires the expiry pipeline now instead of waiting for the real deadline"
            >
              {pendingAction === 'trigger' ? 'Triggering…' : 'Trigger now (dev)'}
            </button>
          </>
        )}
        <button className="link-button danger" onClick={() => run('delete', onDelete)} disabled={busy}>
          {pendingAction === 'delete' ? 'Deleting…' : 'Delete'}
        </button>
      </div>
    </li>
  );
}
