import pytest
from unittest.mock import patch

# The 'client' fixture is automatically available from conftest.py

def test_home_route(client):
    """Test that the home page loads successfully."""
    response = client.get('/')
    assert response.status_code == 200
    assert b"Enter a city name" in response.data

def test_health_check_route(client):
    """Test that the health check endpoint returns a healthy status."""
    response = client.get('/health')
    assert response.status_code == 200
    assert response.json == {"status": "healthy"}

@patch('app.requests.get')
def test_weather_route_success(mock_get, client):
    """
    Test the /weather endpoint with a MOCKED successful API response.
    This test does not make a real network call.
    """
    # Configure the mock to return a successful response
    mock_response = {
        "name": "London",
        "main": {"temp": 15, "humidity": 70},
        "weather": [{"description": "clear sky"}],
        "wind": {"speed": 5},
    }
    mock_get.return_value.status_code = 200
    mock_get.return_value.json.return_value = mock_response
    
    # Simulate a POST request to the /weather endpoint
    response = client.post('/weather', data={'city': 'London'})
    
    assert response.status_code == 200
    assert b"Weather in London" in response.data
    assert b"15" in response.data  # Check for temperature

@patch('app.requests.get')
def test_weather_route_city_not_found(mock_get, client):
    """Test the /weather endpoint with a MOCKED 404 error."""
    # Configure the mock to return a 404 Not Found error
    mock_get.return_value.status_code = 404
    mock_get.return_value.raise_for_status.side_effect = requests.exceptions.HTTPError

    response = client.post('/weather', data={'city': 'InvalidCity'})

    assert response.status_code == 200
    assert b"City not found" in response.data

