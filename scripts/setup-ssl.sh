#!/bin/bash
# Generate self-signed SSL certificates for local development

SSL_DIR="$(dirname "$0")/../nginx/ssl"
mkdir -p "$SSL_DIR"

echo "Generating self-signed SSL certificates..."

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout "$SSL_DIR/selfsigned.key" \
    -out "$SSL_DIR/selfsigned.crt" \
    -subj "/C=IN/ST=Punjab/L=Mohali/O=Difiboffins/CN=localhost"

echo "SSL certificates generated:"
echo "  Certificate: $SSL_DIR/selfsigned.crt"
echo "  Private Key: $SSL_DIR/selfsigned.key"
