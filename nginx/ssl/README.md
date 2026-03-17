# SSL Certificates

This directory holds SSL certificates for the reverse proxy.

## For local development (self-signed):
```bash
make ssl-generate
# or run directly:
./scripts/setup-ssl.sh
```

## For production (Let's Encrypt):
Use certbot with the webroot method:
```bash
certbot certonly --webroot -w /var/www/certbot -d yourdomain.com
```
