import allure
import pytest
import requests

API_BASE_URL="https://api.restful-api.dev"
API_BASE_PATH="/objects"
AUTH_TOKEN=""
headers = {
    'Authorization': f'Bearer {AUTH_TOKEN}',
}

def attach_request_response_to_allure(method, url, request_body, response):
    with allure.step(f"Request: {method} {url}"):
        allure.attach(str(request_body), name="Request Headers", attachment_type=allure.attachment_type.JSON)
    with allure.step(f"Response: {response.status_code}"):
        allure.attach(response.text, name="Response Body", attachment_type=allure.attachment_type.JSON)


@pytest.mark.smoke_test
@pytest.mark.all
@pytest.mark.happy_path
@allure.title("List of all objects")
def test_get_list_of_object():
    response = requests.get(f"{API_BASE_URL}{API_BASE_PATH}", headers=headers)
    url = f"{API_BASE_URL}{API_BASE_PATH}"
    method = "GET"
    response = requests.get(url, headers=headers)
    attach_request_response_to_allure(method, url, None, response)
    assert response.status_code == 200
    data = response.json()
    print(data)
    # assert "items" in data
    # assert isinstance(data["items"], list)

@pytest.mark.smoke_test
@pytest.mark.all
@pytest.mark.happy_path
@allure.title("List of objects by ids")
def test_get_list_of_object_by_id():
    url = f"{API_BASE_URL}{API_BASE_PATH}?id=3&id=5&id=10"
    method = "GET"
    response = requests.get(url, headers=headers)
    attach_request_response_to_allure(method, url, None, response)
    assert response.status_code == 200
    data = response.json()
    print(data)
    # assert "items" in data
    # assert isinstance(data["items"], list)

# @pytest.mark.smoke_test
# @pytest.mark.all
# @pytest.mark.happy_path
# @allure.title("Create Data")
# def test_create_data():
#     payload = {
#         "name": "Sample Item",
#         "value": 100
#     }
#     response = requests.post(f"{API_BASE_URL}/data", json=payload, headers=headers)
#     assert response.status_code == 201
#     data = response.json()
#     assert data["name"] == payload["name"]
#     assert data["value"] == payload["value"]
#     assert "id" in data

