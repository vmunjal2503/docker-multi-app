# ── Stage 1: Install dependencies ──
FROM node:20-alpine AS builder

WORKDIR /app
COPY package.json ./
RUN npm install --omit=dev

# ── Stage 2: Production image ──
FROM node:20-alpine

# Security: run as non-root user
RUN addgroup -S appuser && adduser -S appuser -G appuser

WORKDIR /app

# Copy dependencies from builder
COPY --from=builder /app/node_modules ./node_modules

# Copy application code
COPY app.js .
COPY package.json .

# Switch to non-root user
USER appuser

EXPOSE 3001

CMD ["node", "app.js"]
