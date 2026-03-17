# Docker Multi-App

**Run 3 different apps on one server, each on its own domain, with one command.**

---

## What is this?

You have multiple apps (an API, a frontend, a docs site) and one server. This sets up Nginx to route each domain to the right app — all running in Docker containers.

```
Browser visits app1.example.com  ──┐
Browser visits app2.example.com  ──┤──▶  Nginx  ──▶  Routes to the right app
Browser visits app3.example.com  ──┘

Inside the server:
┌──────────────────────────────────────────┐
│  Nginx (port 80/443)                     │
│    ├── app1.example.com → Flask API      │
│    ├── app2.example.com → Node.js API    │
│    └── app3.example.com → Static website │
└──────────────────────────────────────────┘
```

Start everything:

```bash
docker compose up -d
```

---

## What problem does this solve?

**Without this:** You rent 3 separate servers ($15-60/month each) for 3 apps. Or you try to configure Nginx manually — spend a day writing config files, debugging SSL, and forgetting security headers. Every new app requires 2 hours of setup.

**With this:** All apps share one server. Nginx routes traffic automatically. SSL, rate limiting, compression, and security headers are pre-configured. Adding a new app takes 5 minutes — copy one config file, add 3 lines to docker-compose.

---

## What's included?

| Component | What it does |
|-----------|-------------|
| **Nginx reverse proxy** | Receives all traffic on port 80/443 and routes it to the correct app based on the domain name |
| **Flask API** (Python) | Sample API running on Gunicorn — replace with your own Python app |
| **Node.js API** | Sample Express.js API — replace with your own Node app |
| **Static site** | HTML/CSS served by Nginx — replace with your built React/Vue/Angular app |
| **SSL certificates** | Self-signed for local development, easy swap to Let's Encrypt for production |
| **Security headers** | X-Frame-Options, Content-Security-Policy, HSTS — protects against common attacks |
| **Rate limiting** | 10 requests/second per IP — prevents abuse |
| **Gzip compression** | Compresses responses — pages load faster |
| **Health checks** | Docker monitors each app and restarts it if it crashes |

---

## How to use it

```bash
# 1. Clone
git clone https://github.com/vmunjal2503/docker-multi-app.git
cd docker-multi-app

# 2. Generate SSL certificates for local testing
make ssl-generate

# 3. Add local domains to your computer
echo "127.0.0.1 app1.localhost app2.localhost app3.localhost" | sudo tee -a /etc/hosts

# 4. Start everything
make up

# 5. Test — each domain goes to a different app
curl http://app1.localhost/health    # → Flask API responds
curl http://app2.localhost/health    # → Node.js API responds
curl http://app3.localhost           # → Static website loads
```

## How to add your own app

1. Put your app in `apps/my-app/` with a `Dockerfile`
2. Add it to `docker-compose.yml` (copy an existing service, change the name)
3. Create `nginx/conf.d/my-app.conf` (copy an existing one, change the domain)
4. Run `make up`

That's it. 5 minutes.

---

## How is the code organized?

```
docker-multi-app/
├── docker-compose.yml          # Defines all containers and how they connect
├── nginx/
│   ├── nginx.conf              # Main Nginx config (compression, rate limits, security)
│   └── conf.d/
│       ├── app1.conf           # Routes app1.localhost → Flask API
│       ├── app2.conf           # Routes app2.localhost → Node.js API
│       └── app3.conf           # Routes app3.localhost → Static site
├── apps/
│   ├── flask-api/              # Python API (Flask + Gunicorn)
│   ├── node-api/               # Node.js API (Express)
│   └── static-site/            # Plain HTML/CSS website
├── scripts/
│   ├── setup-ssl.sh            # Generate self-signed SSL certs
│   └── health-check.sh         # Check if all apps are running
└── Makefile                    # Shortcuts: make up, make down, make logs, make health
```

---

## Who is this for?

- Anyone running multiple apps on one VPS/EC2 and tired of configuring Nginx by hand
- Freelancers deploying client projects that need API + frontend on one server
- Teams that want a quick local dev environment with multiple services

---

Built by **Vikas Munjal** | Open source under MIT License
