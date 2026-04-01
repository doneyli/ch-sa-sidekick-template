import warnings

warnings.filterwarnings("ignore", message=".*urllib3.*OpenSSL.*")

import requests

# ClickHouse Query API endpoint configuration
SERVICE_ID = "45f06a88-e235-4461-8d9f-b6fa39fe4722"
API_KEY_ID = "LBCbzi9N465Kv4gHoqKu"
API_KEY_SECRET = "4b1dxpKT6NdxJHWpr4ps0GTu9kI7B5Xgehc2ifYr81"

ENDPOINT_URL = f"https://queries.clickhouse.cloud/service/{SERVICE_ID}/run"


def run_query(sql: str, format: str = "JSONEachRow") -> requests.Response:
    """Execute a query against the ClickHouse Query API endpoint."""
    response = requests.post(
        ENDPOINT_URL,
        params={"format": format},
        auth=(API_KEY_ID, API_KEY_SECRET),
        headers={"Content-Type": "application/json"},
        json={"sql": sql},
    )
    response.raise_for_status()
    return response


if __name__ == "__main__":
    result = run_query("""                                                                                                                                                  
      CREATE TABLE dummy_table2
(
    id UInt32,
    name String,
    created_date Date,
    price Float64
)
ENGINE = MergeTree()
ORDER BY id;                                                                                                                       
  """)
    print(result.text)
