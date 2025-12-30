import allure
import pytest
import requests

API_BASE_URL="https://api.restful-api.dev"
API_BASE_PATH="/objects"
AUTH_TOKEN=""
headers = {
    'Authorization': f'Bearer {AUTH_TOKEN}',
}
@pytest.mark.smoke_test
@pytest.mark.all
@pytest.mark.happy_path
@allure.title("Get Data")
def test_get_data():
    response = requests.get(f"{API_BASE_URL}{API_BASE_PATH}", headers=headers)
    # assert response.status_code == 200
    data = response.json()
    print(data)
    # assert "items" in data
    # assert isinstance(data["items"], list)

@pytest.mark.smoke_test
@pytest.mark.all
@pytest.mark.happy_path
@allure.title("Create Data")
def test_create_data():
    payload = {
        "name": "Sample Item",
        "value": 100
    }
    response = requests.post(f"{API_BASE_URL}/data", json=payload, headers=headers)
    assert response.status_code == 201
    data = response.json()
    assert data["name"] == payload["name"]
    assert data["value"] == payload["value"]
    assert "id" in data

