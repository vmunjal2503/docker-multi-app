"""Flask API — Sample microservice behind Nginx reverse proxy."""

import os
import logging
from datetime import datetime, timezone
from flask import Flask, jsonify

app = Flask(__name__)

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

APP_NAME = os.environ.get("APP_NAME", "flask-api")
VERSION = "1.0.0"
START_TIME = datetime.now(timezone.utc)


@app.route("/health")
def health():
    """Health check endpoint for Docker and load balancer."""
    uptime = (datetime.now(timezone.utc) - START_TIME).total_seconds()
    return jsonify({
        "status": "healthy",
        "service": APP_NAME,
        "uptime_seconds": round(uptime, 1)
    })


@app.route("/api/info")
def info():
    """Service information endpoint."""
    return jsonify({
        "app": "Flask API",
        "version": VERSION,
        "framework": "Flask",
        "runtime": "Python",
        "timestamp": datetime.now(timezone.utc).isoformat()
    })


@app.route("/")
def root():
    """Root endpoint."""
    return jsonify({
        "message": f"Welcome to {APP_NAME}",
        "docs": "/api/info",
        "health": "/health"
    })


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5001, debug=False)
