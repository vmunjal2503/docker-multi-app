# Docker Multi-App

**Run 3 different apps on one server, each on its own domain, with one command.**

---

## What is this?

You have multiple apps (an API, a frontend, a docs site) and one server. This sets up Nginx as a reverse proxy to route each domain to the right app — all running in Docker containers.

```
Browser visits app1.example.com  ──┐
Browser visits app2.example.com  ──┤──▶  Nginx  ──▶  Routes to the right container
Browser visits app3.example.com  ──┘

Inside the server:
┌───────────────────────────────────────────────────────┐
│  Nginx (port 80/443) — reverse proxy                  │
│    ├── app1.example.com → Flask API    (port 5000)    │
│    ├── app2.example.com → Node.js API  (port 3000)    │
│    └── app3.example.com → Static site  (served by Nginx directly) │
│                                                       │
│  Docker network: all containers on 'app-network'      │
│  Containers talk via service names, not IPs            │
└───────────────────────────────────────────────────────┘
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

| Component | What it does | Technical Details |
|-----------|-------------|-------------------|
| **Nginx reverse proxy** | Receives all traffic and routes based on `Host` header | Layer 7 routing via `server_name` directive. `proxy_pass` to upstream containers using Docker DNS. Connection pooling with `keepalive 32`. |
| **Flask API** (Python) | Sample REST API — replace with your own | Multi-stage Dockerfile: build stage installs deps, production stage runs Gunicorn with 4 workers (`--workers 4 --bind 0.0.0.0:5000`). |
| **Node.js API** | Sample Express.js API — replace with your own | Multi-stage Dockerfile: `node:alpine` base, non-root user, `NODE_ENV=production`. Health endpoint at `/health`. |
| **Static site** | HTML/CSS served directly by Nginx | No separate container needed — Nginx serves static files from a mounted volume. `try_files` with SPA fallback ready. |
| **SSL/TLS** | HTTPS termination at Nginx | Self-signed certs for dev (generated via `openssl`). In production: swap to Let's Encrypt with certbot auto-renewal. TLS 1.2+ only, strong cipher suite. |
| **Security headers** | Protects against XSS, clickjacking, MIME sniffing | `X-Frame-Options: DENY`, `X-Content-Type-Options: nosniff`, `Content-Security-Policy`, `Strict-Transport-Security` (HSTS with 1-year max-age). |
| **Rate limiting** | Prevents brute-force and DDoS | `limit_req_zone` at 10 req/s per IP with burst of 20. Returns `429 Too Many Requests` when exceeded. |
| **Gzip compression** | Smaller response sizes | Compresses `text/html`, `application/json`, `text/css`, `application/javascript`. Min size 1KB. Compression level 6. |
| **Health checks** | Docker restarts crashed containers | `healthcheck` in docker-compose: `curl --fail http://localhost/health` every 30s, 3 retries, 5s timeout. |

---

## Architecture patterns used

- **Reverse proxy pattern** — Nginx sits in front of all apps. Clients never talk to app containers directly. This gives you one place to handle SSL, auth, rate limiting, and logging.
- **Docker service discovery** — Containers reference each other by service name (e.g., `proxy_pass http://flask-api:5000`). Docker's internal DNS resolves it. No hardcoded IPs.
- **Multi-stage builds** — Dockerfiles use 2 stages: one to install dependencies, one to run the app. Final images are 60-80% smaller (no build tools, no dev dependencies in production).
- **Shared Docker network** — All containers join `app-network` (bridge driver). Nginx can reach all apps, but apps can't be accessed directly from outside the Docker network.
- **Config-driven scaling** — Each app's Nginx config is a separate file in `conf.d/`. Adding a new app = adding a new `.conf` file. Nginx auto-includes all files in `conf.d/`.

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
3. Create `nginx/conf.d/my-app.conf` (copy an existing one, change the `server_name` and `proxy_pass`)
4. Run `make up`

That's it. 5 minutes.

---

## How is the code organized?

```
docker-multi-app/
├── docker-compose.yml          # Defines all containers, networks, volumes, health checks
├── nginx/
│   ├── nginx.conf              # Main config: worker processes, gzip, rate limits, security headers
│   └── conf.d/
│       ├── app1.conf           # Virtual host: app1.localhost → flask-api:5000
│       ├── app2.conf           # Virtual host: app2.localhost → node-api:3000
│       └── app3.conf           # Virtual host: app3.localhost → static files
├── apps/
│   ├── flask-api/              # Python API (Flask + Gunicorn, multi-stage Dockerfile)
│   ├── node-api/               # Node.js API (Express, non-root user, alpine base)
│   └── static-site/            # Plain HTML/CSS (served directly by Nginx)
├── scripts/
│   ├── setup-ssl.sh            # Generates self-signed certs with openssl
│   └── health-check.sh         # Hits /health on all apps, reports status
└── Makefile                    # Shortcuts: make up, make down, make logs, make health
```

---

## Who is this for?

- Anyone running multiple apps on one VPS/EC2 and tired of configuring Nginx by hand
- Freelancers deploying client projects that need API + frontend on one server
- Teams that want a quick local dev environment with multiple services behind a reverse proxy

---

Built by **Vikas Munjal** | Open source under MIT License
