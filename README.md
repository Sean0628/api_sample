# README
## Setup Instructions

1. **Clone the Repository**:

    ```sh
    git clone git@github.com:Sean0628/api_sample.git
    ```

    ```sh
    cd api_sample
    ```

2. **Start the Services**:

    ```sh
    docker-compose up -d
    ```

3. **Database Setup**:

    Create the database:

    ```sh
    docker-compose run --rm api rails db:create
    ```

    Run the migrations:

    ```sh
    docker-compose run --rm api rails db:migrate
    ```

## Getting Started

- **Get an API Key**:

```sh
docker-compose run --rm api rails runner ./scripts/create_api_key.rb
```

---

## Endpoints
### Add Endpoint

**URL:** `/geolocations`
**Method:** `POST`
**Authentication:** Requires API Key in `X-Api-Key` header

**Description:** Adds a new geolocation record to the database based on the provided IP address or URL. If both `ip_address` and `url` are provided, `ip_address` will be prioritized. If a URL is provided, it will resolve the IP address and store the corresponding geolocation data.

**Request:**
```json
{
  "data": {
    "attributes": {
      "ip_address": "134.201.250.155",
      "url": "http://example.com"
    }
  }
}
```

**Response:**
- **201 Created:** When the geolocation record is successfully created.
- **422 Unprocessable Entity:** When the provided data is invalid.

**Example Response:**
```json
{
    "_id": "66c23d6dd9f6cb76133a9692",
    "created_at": "2024-08-18T18:29:01.996Z",
    "data": {
        "ip": "140.82.112.3",
        ...
    },
    "ip": "140.82.112.3",
    "updated_at": "2024-08-18T18:29:01.996Z"
}
```

### Delete Endpoint

**URL:** `/geolocations`
**Method:** `DELETE`
**Authentication:** Requires API Key in `X-Api-Key` header

**Description:** Deletes a geolocation record from the database based on the provided IP address or URL. If a URL is provided, it will resolve the IP address and delete the corresponding geolocation record.

**Request:**
```json
{
  "data": {
    "attributes": {
      "ip_address": "134.201.250.155",
      "url": "http://example.com"
    }
  }
}
```

**Response:**
- **204 No Content:** When the geolocation record is successfully deleted.
- **404 Not Found:** When the record is not found in the database.
- **422 Unprocessable Entity:** When the provided data is invalid or the record cannot be deleted.

### Provide (Show) Endpoint

**URL:** `/geolocations/provide`
**Method:** `GET`
**Authentication:** Requires API Key in `X-Api-Key` header

**Description:** Retrieves a geolocation record from the database based on the provided IP address or URL. If both `ip_address` and `url` are provided, `ip_address` will be prioritized. If a URL is provided, it will resolve the IP address and retrieve the corresponding geolocation record. If the record is not found in the database, it will attempt to fetch it from an external provider and save it.

**Request:**
```json
{
  "data": {
    "attributes": {
      "ip_address": "134.201.250.155",
      "url": "http://example.com"
    }
  }
}
```

**Response:**
- **200 OK:** When the geolocation record is successfully retrieved from the database or cache.
- **201 Created:** When the geolocation record is fetched from the external provider and saved.
- **422 Unprocessable Entity:** When the provided data is invalid.

**Example Response:**
```json
{
    "_id": "66c23d6dd9f6cb76133a9692",
    "created_at": "2024-08-18T18:29:01.996Z",
    "data": {
        "ip": "140.82.112.3",
        ...
    },
    "ip": "140.82.112.3",
    "updated_at": "2024-08-18T18:29:01.996Z"
}
```
