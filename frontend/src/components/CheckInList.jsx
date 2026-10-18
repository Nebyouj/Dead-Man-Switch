import { CheckInCard } from './CheckInCard';

export function CheckInList({ checkIns, onCheckIn, onCancel, onDelete, onTrigger }) {
  if (checkIns.length === 0) {
    return <p className="empty-state">No check-ins yet — create one above to get started.</p>;
  }

  return (
    <ul className="checkin-list">
      {checkIns.map((c) => (
        <CheckInCard
          key={c.id}
          checkIn={c}
          onCheckIn={onCheckIn}
          onCancel={onCancel}
          onDelete={onDelete}
          onTrigger={onTrigger}
        />
      ))}
    </ul>
  );
}
