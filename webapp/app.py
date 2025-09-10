from flask import Flask, jsonify
import os
import psycopg2

app = Flask(__name__)

db_host = os.getenv("DB_HOST", "localhost")  # if it doesn't find env input, it automatically assign it to localhost
db_name = os.getenv("DB_NAME", "appdb")
db_user = os.getenv("DB_USER", "appuser")
db_password = os.getenv("DB_PASSWORD", "password")


# User-facing route
@app.route("/")  
def index():
    return "Welcome to Mye Flask App!"

# Health check route
@app.route("/health")
def health():
    try:
        # Try to connect with database
        conn = psycopg2.connect(
            host=db_host,
            dbname=db_name,
            user=db_user,
            password=db_password
        )
        conn.close()
        db_status = "connected"
        
    except Exception as e:
        db_status = f"error: {e}"
        
    # Return JSON with status
    status = {
        "app": "ok",
        "db": db_status
    }
    
    # If DB connection failed, return HTTP 500
    if "error" in db_status:
        return jsonify(status), 500
    return jsonify(status)


# Run Flask App
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
