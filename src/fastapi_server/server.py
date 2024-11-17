from fastapi import FastAPI, Request
from fastapi.responses import HTMLResponse

app = FastAPI()

last_request_body = ""  # Variable to store the last received request body

html_content = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Request Body</title>
</head>
<body>
    <h1>Request Body:</h1>
    <pre id="request-body">{}</pre>
</body>
</html>
"""

@app.get("/index")
async def index():
    global last_request_body  # Access the global variable
    return HTMLResponse(content=html_content.format(last_request_body), status_code=200, media_type="text/html")

@app.post("/")
async def post(request: Request):
    global last_request_body  # Access the global variable
    last_request_body = await request.body()
    return last_request_body
