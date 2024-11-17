import time
import json
import requests


cnt = 0
while True:
    status = requests.post('https://test-vnet-st-server.azurewebsites.net/post', data=json.dumps({'Message': f'Hello from Streamlit {cnt}!'}))
    print(status.status_code)
    cnt += 1
    time.sleep(5)
