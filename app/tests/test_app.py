def test_health_ok(client):
    r = client.get("/health")
    assert r.status_code == 200  # ALB requires 200 [web:464]

def test_homepage_reachable(client):
    r = client.get("/")
    assert r.status_code in (200, 301, 302)

def test_404_for_unknown_path(client):
    r = client.get("/__does_not_exist__")
    assert r.status_code == 404
