import pytest
from app import app

@pytest.fixture
def client(monkeypatch):
    # Default: present a fake API key so tests don't depend on real credentials
    monkeypatch.setenv('API_KEY', 'FAKE_API_KEY')
    app.config['TESTING'] = True
    with app.test_client() as c:
        yield c

def test_health(client):
    res = client.get('/health')
    assert res.status_code == 200
    assert res.get_json() == {"status": "healthy", "version": "1.0.0"}

def test_home_missing_key(monkeypatch):
    # For this test, ensure key is absent before making the request
    monkeypatch.delenv('API_KEY', raising=False)
    app.config['TESTING'] = True
    with app.test_client() as c:
        res = c.get('/')
    assert res.status_code == 200
    assert b"API key is missing" in res.data

def test_weather_empty_city(client):
    res = client.post('/weather', data={'city': ''})
    assert res.status_code == 200
    assert b"Please enter a city name." in res.data
