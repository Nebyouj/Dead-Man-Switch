import { useState } from 'react';

const initialState = {
  name: '',
  message: '',
  recipient_email: '',
  recipient_phone: '',
  channels: ['email'],
  duration_minutes: 1440,
};

export function CheckInForm({ onCreate }) {
  const [form, setForm] = useState(initialState);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState(null);

  function toggleChannel(channel) {
    setForm((f) => ({
      ...f,
      channels: f.channels.includes(channel)
        ? f.channels.filter((c) => c !== channel)
        : [...f.channels, channel],
    }));
  }

  async function handleSubmit(e) {
    e.preventDefault();
    setError(null);
    setSubmitting(true);
    try {
      const payload = {
        name: form.name,
        message: form.message || undefined,
        duration_minutes: Number(form.duration_minutes),
        channels: form.channels,
      };
      // Only send the recipient fields the API actually needs — sending an
      // empty string for an unused channel would fail email/phone format
      // validation for no reason.
      if (form.channels.includes('email')) payload.recipient_email = form.recipient_email;
      if (form.channels.includes('sms')) payload.recipient_phone = form.recipient_phone;

      await onCreate(payload);
      setForm(initialState);
    } catch (err) {
      setError(err.message);
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <form className="checkin-form" onSubmit={handleSubmit}>
      <h2>New check-in</h2>

      <label>
        Name
        <input
          value={form.name}
          onChange={(e) => setForm({ ...form, name: e.target.value })}
          required
        />
      </label>

      <label>
        Message (optional)
        <textarea
          value={form.message}
          onChange={(e) => setForm({ ...form, message: e.target.value })}
          rows={2}
        />
      </label>

      <fieldset>
        <legend>Notify via</legend>
        <label className="checkbox">
          <input
            type="checkbox"
            checked={form.channels.includes('email')}
            onChange={() => toggleChannel('email')}
          />
          Email
        </label>
        <label className="checkbox">
          <input
            type="checkbox"
            checked={form.channels.includes('sms')}
            onChange={() => toggleChannel('sms')}
          />
          SMS
        </label>
      </fieldset>

      {form.channels.includes('email') && (
        <label>
          Recipient email
          <input
            type="email"
            value={form.recipient_email}
            onChange={(e) => setForm({ ...form, recipient_email: e.target.value })}
            required
          />
        </label>
      )}

      {form.channels.includes('sms') && (
        <label>
          Recipient phone
          <input
            value={form.recipient_phone}
            onChange={(e) => setForm({ ...form, recipient_phone: e.target.value })}
            placeholder="+2519..."
            required
          />
        </label>
      )}

      <label>
        Expires after (minutes)
        <input
          type="number"
          min="1"
          value={form.duration_minutes}
          onChange={(e) => setForm({ ...form, duration_minutes: e.target.value })}
          required
        />
      </label>

      {error && <p className="form-error">{error}</p>}

      <button type="submit" disabled={submitting}>
        {submitting ? 'Creating…' : 'Create check-in'}
      </button>
    </form>
  );
}
