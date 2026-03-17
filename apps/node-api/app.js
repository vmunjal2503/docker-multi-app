/**
 * Node.js Express API — Sample microservice behind Nginx reverse proxy.
 */

const express = require("express");

const app = express();
const PORT = 3001;
const APP_NAME = process.env.APP_NAME || "node-api";
const VERSION = "1.0.0";
const START_TIME = new Date();

// Health check endpoint
app.get("/health", (req, res) => {
  const uptimeSeconds = (Date.now() - START_TIME.getTime()) / 1000;
  res.json({
    status: "healthy",
    service: APP_NAME,
    uptime_seconds: Math.round(uptimeSeconds * 10) / 10,
  });
});

// Service info endpoint
app.get("/api/info", (req, res) => {
  res.json({
    app: "Node API",
    version: VERSION,
    framework: "Express",
    runtime: "Node.js",
    timestamp: new Date().toISOString(),
  });
});

// Root endpoint
app.get("/", (req, res) => {
  res.json({
    message: `Welcome to ${APP_NAME}`,
    docs: "/api/info",
    health: "/health",
  });
});

app.listen(PORT, "0.0.0.0", () => {
  console.log(`${APP_NAME} running on port ${PORT}`);
});
