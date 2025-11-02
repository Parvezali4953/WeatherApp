# /app/tests/test_app.py

import pytest
from app import app

# This is a standard pytest "fixture" that creates a test client for your app.
@pytest.fixture
def client():
    app.config.update({"TESTING": True})
    with app.test_client() as client:
        yield client

# -----------------------------------------------------------------------------
# THIS IS THE ONLY TEST THAT MATTERS FOR YOUR DEVOPS PORTFOLIO
# -----------------------------------------------------------------------------
def test_health_check_returns_ok(client):
    """
    GIVEN a running Flask application
    WHEN the '/health' endpoint is requested (by the ALB)
    THEN check that it returns a '200 OK' status code.
    
    This test ensures that our application will always be considered "healthy"
    by the load balancer, preventing 502 errors caused by bad deployments.
    """
    response = client.get("/health")
    assert response.status_code == 200
