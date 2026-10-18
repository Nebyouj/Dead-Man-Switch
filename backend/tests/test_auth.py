def test_register_user(client):
    response = client.post(
        "/auth/register", json={"email": "alice@example.com", "password": "supersecret1"}
    )
    assert response.status_code == 201
    body = response.json()
    assert body["email"] == "alice@example.com"
    assert "password" not in body
    assert "password_hash" not in body


def test_duplicate_email(client):
    client.post("/auth/register", json={"email": "bob@example.com", "password": "supersecret1"})
    response = client.post(
        "/auth/register", json={"email": "bob@example.com", "password": "anotherpass1"}
    )
    assert response.status_code == 400


def test_login(client):
    client.post("/auth/register", json={"email": "carol@example.com", "password": "supersecret1"})
    response = client.post(
        "/auth/login", data={"username": "carol@example.com", "password": "supersecret1"}
    )
    assert response.status_code == 200
    body = response.json()
    assert "access_token" in body
    assert body["token_type"] == "bearer"


def test_invalid_password(client):
    client.post("/auth/register", json={"email": "dave@example.com", "password": "supersecret1"})
    response = client.post(
        "/auth/login", data={"username": "dave@example.com", "password": "wrongpassword"}
    )
    assert response.status_code == 401
