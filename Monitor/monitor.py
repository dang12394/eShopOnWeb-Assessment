import requests
import time
import os
from datetime import datetime
import sys

URL = "http://localhost:8080"
LOG_FILE = os.path.join(os.path.dirname(__file__), "log.txt")
INTERVAL = 60  

def log(msg):
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    with open(LOG_FILE, "a") as f:
        f.write(f"{timestamp} - {msg}\n")
    print(f"{timestamp} - {msg}")

log(f"Service started. Monitoring {URL} every {INTERVAL} seconds.")

while True:
    try:
        response = requests.get(URL, timeout=10)
        status_code = response.status_code
        status_msg = response.reason
        log(f"HTTP {status_code} - {status_msg}")

        if status_code != 200:
            log("Non-200 response. Exiting service.")
            sys.exit(1)
    except Exception as e:
        log(f"ERROR: {e}")
        sys.exit(1)

    time.sleep(INTERVAL)