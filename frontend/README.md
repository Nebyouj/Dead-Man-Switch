# Dead Man's Switch — Web Dashboard

A plain React SPA against the backend API: register/login (including
Google Sign-In), and create/list/check-in/cancel/delete your check-ins.
This is Phase 2 of the project — function over polish. The visual design
pass is Phase 3.

## Running it

You need the backend running first (see the backend's own README —
`docker compose up --build`, or a local `uvicorn` run). By default this
expects it at `http://localhost:8000`.

```bash
npm install
cp .env.example .env   # edit if your backend isn't on localhost:8000
npm run dev
```

Opens at `http://localhost:5173`.

## Structure

```text
src/
├── main.jsx              Router + AuthProvider setup
├── App.jsx                Route table
├── api/
│   └── client.js          fetch wrapper: JSON handling, auth header, error parsing
├── auth/
│   ├── AuthContext.jsx     JWT state, persisted in localStorage, login/register/logout
│   └── RequireAuth.jsx     Route guard -- redirects to /login if not authenticated
├── pages/
│   ├── LoginPage.jsx       Email/password + optional "Sign in with Google" button
│   ├── RegisterPage.jsx
│   └── DashboardPage.jsx   Fetches check-ins, owns loading/error state, wires up actions
├── components/
│   ├── CheckInForm.jsx     Create form -- channel checkboxes show/hide recipient fields
│   ├── CheckInList.jsx     Empty state + list
│   └── CheckInCard.jsx     One check-in: status badge, deadline, per-action loading/error
└── index.css               Functional styling only -- no design pass yet
```

## Notes on a few decisions

- **Token storage**: the JWT lives in `localStorage` so a page refresh
  doesn't log you out. That's a deliberate simplification, not a final
  security posture -- `localStorage` is readable by any script on the page.
  If this app ever handles something more sensitive than check-in timers,
  swap it for an httpOnly cookie issued by the backend instead.
- **Deadline timezone**: the API returns naive UTC timestamps (no `Z`
  suffix). `CheckInCard` appends one before parsing -- without that, the
  browser reads the timestamp as local time and shows the wrong hour for
  anyone not in UTC.
- **Google Sign-In is optional**: the button only renders if
  `VITE_GOOGLE_CLIENT_ID` is set (same Client ID as the backend's
  `GOOGLE_CLIENT_ID`). Leave it unset and the login page just shows the
  regular form.
- **"Trigger now (dev)"** on each active check-in calls the backend's
  dev-only `/trigger` endpoint directly -- useful for demoing the full
  expiry flow without waiting, but it's gated server-side by `DEBUG` and
  should come out (or be hidden) before this is ever a real product.
- **Error messages**: `api/client.js` normalizes FastAPI's error shape --
  both the simple `{"detail": "..."}` string and Pydantic's validation
  array -- into one readable string, so every page can just render
  `err.message`.

## Known lint notes

`npm run lint` reports two non-blocking warnings, both intentional,
common React patterns rather than bugs:
- `DashboardPage.jsx` calls `refresh()` inside a `useEffect` on mount --
  the standard fetch-on-mount pattern.
- `AuthContext.jsx` exports both the `AuthProvider` component and the
  `useAuth` hook from one file -- the usual React Context + hook pairing.

## What's next (Phase 3)

Design pass (real typography/spacing, a component library, proper
empty/error states) plus an admin view gated behind a role -- see the
project's phased roadmap.
