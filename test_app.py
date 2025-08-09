import pytest
from app import app

@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_health_check(client, mocker):
    """
    Test the /health endpoint to ensure it returns a 200 OK status.
    """
    mocker.patch.dict('os.environ', {'API_KEY': 'FAKE_API_KEY'})

    response = client.get('/health')
    assert response.status_code == 200
    assert response.json == {"status": "healthy", "version": "1.0.0"}
