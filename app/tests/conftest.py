import os
import pytest

os.environ.setdefault("FLASK_ENV", "testing")
os.environ.setdefault("API_KEY", "test")

@pytest.fixture()
def client():
    from app import app
    app.config.update(TESTING=True)
    with app.test_client() as c:
        yield c
