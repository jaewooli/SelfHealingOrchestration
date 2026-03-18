from flask import Flask, request, jsonify

app = Flask(__name__)

@app.get("/")
def home():
    return jsonify({
        "message": "test server is running",
        "endpoints": [
            "/search?q=",
            "/download?file=",
            "/fetch?url=",
            "/admin",
            "/echo"
        ]
    })

@app.get("/search")
def search():
    q = request.args.get("q", "")
    return jsonify({
        "endpoint": "search",
        "q": q
    })

@app.get("/download")
def download():
    file_name = request.args.get("file", "")
    return jsonify({
        "endpoint": "download",
        "file": file_name
    })

@app.get("/fetch")
def fetch():
    target_url = request.args.get("url", "")
    return jsonify({
        "endpoint": "fetch",
        "url": target_url
    })

@app.get("/admin")
def admin():
    return jsonify({
        "endpoint": "admin",
        "message": "Fake admin page"
    })

@app.post("/echo")
def echo():
    body = request.get_data(as_text=True)
    return jsonify({
        "endpoint": "echo",
        "body": body
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)