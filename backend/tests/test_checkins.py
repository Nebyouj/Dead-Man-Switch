def _create_checkin(client, headers, **overrides):
    payload = {
        "name": "Daily Check-in",
        "message": "hi",
        "recipient_email": "friend@example.com",
        "duration_minutes": 60,
    }
    payload.update(overrides)
    return client.post("/checkins", json=payload, headers=headers)


def test_create_checkin(client, auth_headers):
    response = _create_checkin(client, auth_headers)
    assert response.status_code == 201
    body = response.json()
    assert body["status"] == "ACTIVE"
    assert body["name"] == "Daily Check-in"


def test_create_checkin_requires_auth(client):
    response = _create_checkin(client, headers={})
    assert response.status_code == 401


def test_get_checkins(client, auth_headers):
    _create_checkin(client, auth_headers, name="A")
    response = client.get("/checkins", headers=auth_headers)
    assert response.status_code == 200
    assert len(response.json()) == 1


def test_get_single_checkin(client, auth_headers):
    created = _create_checkin(client, auth_headers).json()
    response = client.get(f"/checkins/{created['id']}", headers=auth_headers)
    assert response.status_code == 200
    assert response.json()["id"] == created["id"]


def test_get_single_checkin_not_found(client, auth_headers):
    response = client.get("/checkins/999999", headers=auth_headers)
    assert response.status_code == 404


def test_check_in_resets_deadline(client, auth_headers):
    created = _create_checkin(client, auth_headers).json()
    response = client.post(f"/checkins/{created['id']}/check-in", headers=auth_headers)
    assert response.status_code == 200
    assert response.json()["status"] == "ACTIVE"


def test_cancel_checkin(client, auth_headers):
    created = _create_checkin(client, auth_headers).json()
    response = client.post(f"/checkins/{created['id']}/cancel", headers=auth_headers)
    assert response.status_code == 200
    assert response.json()["status"] == "CANCELLED"


def test_cannot_check_in_after_cancel(client, auth_headers):
    created = _create_checkin(client, auth_headers).json()
    client.post(f"/checkins/{created['id']}/cancel", headers=auth_headers)
    response = client.post(f"/checkins/{created['id']}/check-in", headers=auth_headers)
    assert response.status_code == 400


def test_delete_checkin(client, auth_headers):
    created = _create_checkin(client, auth_headers).json()
    response = client.delete(f"/checkins/{created['id']}", headers=auth_headers)
    assert response.status_code == 204
    assert client.get(f"/checkins/{created['id']}", headers=auth_headers).status_code == 404


def _headers_for_new_user(client, email):
    client.post("/auth/register", json={"email": email, "password": "supersecret1"})
    token = client.post(
        "/auth/login", data={"username": email, "password": "supersecret1"}
    ).json()["access_token"]
    return {"Authorization": f"Bearer {token}"}


def test_user_cannot_access_other_users_checkin(client):
    headers_a = _headers_for_new_user(client, "userA@example.com")
    created = _create_checkin(client, headers_a).json()

    headers_b = _headers_for_new_user(client, "userB@example.com")
    response = client.get(f"/checkins/{created['id']}", headers=headers_b)
    assert response.status_code == 404
