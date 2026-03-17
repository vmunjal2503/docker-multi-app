# Docker Multi-App — Nginx Reverse Proxy Setup

Production-ready Docker Compose setup running 3 different apps behind an Nginx reverse proxy with SSL, rate limiting, and security headers.

## Why I Built This

**The Problem:** Startups and small teams often run multiple services (API, frontend, admin panel, docs) on a single server to save costs. But configuring Nginx to route traffic to each app, setting up SSL, adding security headers, and making it all work with Docker is tedious, error-prone, and poorly documented. Most tutorials cover the basics but skip rate limiting, gzip, health checks, and production hardening.

**The Solution:** One `docker compose up -d` command gives you a fully configured Nginx reverse proxy routing to 3 apps — with SSL, rate limiting, gzip compression, security headers, and health monitoring out of the box. Need to add a 4th app? Copy one config file, add 3 lines to docker-compose, done.

**Built from real client work** — I've set up this exact pattern for multiple Upwork clients running multi-app servers on AWS EC2. This template captures everything I've learned about doing it right.

```
                    ┌───────────────────────────────────────────────┐
                    │              Docker Network                   │
                    │                                               │
 ┌──────────┐      │  ┌─────────────────────────────────────────┐  │
 │  Client   │──────│─▶│   Nginx Reverse Proxy (:80 / :443)     │  │
 │  Browser  │      │  │   - SSL termination                    │  │
 └──────────┘      │  │   - Rate limiting (10 req/s)           │  │
                    │  │   - Gzip compression                   │  │
                    │  │   - Security headers                   │  │
                    │  └──┬──────────┬──────────┬───────────────┘  │
                    │     │          │          │                   │
                    │     ▼          ▼          ▼                   │
                    │  ┌──────┐  ┌──────┐  ┌──────────┐           │
                    │  │Flask │  │Node  │  │  Static  │           │
                    │  │ API  │  │ API  │  │   Site   │           │
                    │  │:5001 │  │:3001 │  │  :8080   │           │
                    │  └──────┘  └──────┘  └──────────┘           │
                    │  Gunicorn   Express    Nginx                  │
                    │  Python     Node.js    HTML/CSS               │
                    └───────────────────────────────────────────────┘

 Routing:
   app1.localhost  →  Flask API   (Python + Gunicorn)
   app2.localhost  →  Node API    (Express.js)
   app3.localhost  →  Static Site (Nginx serving HTML)
```

## Features

- **Nginx reverse proxy** with virtual host routing
- **3 sample apps** (Flask, Node.js, Static) — easily add more
- **SSL ready** (self-signed certs for dev, Let's Encrypt for prod)
- **Security headers** (X-Frame-Options, CSP, HSTS, etc.)
- **Rate limiting** (10 requests/second per IP)
- **Gzip compression** for faster responses
- **Health checks** on all containers
- **Non-root containers** for security
- **Multi-stage Docker builds** for smaller images

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) >= 20.10
- [Docker Compose](https://docs.docker.com/compose/) >= 2.0

## Quick Start

```bash
# 1. Clone
git clone https://github.com/yourusername/docker-multi-app.git
cd docker-multi-app

# 2. Generate SSL certs (self-signed for local dev)
make ssl-generate

# 3. Add hosts entries (for local testing)
echo "127.0.0.1 app1.localhost app2.localhost app3.localhost" | sudo tee -a /etc/hosts

# 4. Start everything
make up

# 5. Test
curl http://app1.localhost/health    # Flask API
curl http://app2.localhost/health    # Node API
curl http://app3.localhost            # Static site
```

## How to Add a New App

1. Create `apps/my-new-app/` with a `Dockerfile`
2. Add a service in `docker-compose.yml`
3. Create `nginx/conf.d/my-new-app.conf` (copy an existing one)
4. Run `make up`

## Commands

```bash
make up           # Start all containers
make down         # Stop all containers
make logs         # View all logs
make health       # Check health of all apps
make ssl-generate # Generate self-signed SSL certificates
make restart      # Restart all containers
make build        # Rebuild all images
make clean        # Remove containers, images, and volumes
```

---

Built by **Vikas Munjal** | Open source under MIT License
