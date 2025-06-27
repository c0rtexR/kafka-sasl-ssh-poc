#!/usr/bin/env bash
# Generate self-signed TLS material for the single-node Kafka instance.
#
# The files created match the names expected by docker-compose.yml:
#   certs/
#     ├─ ca.crt                 – Certificate Authority             (public)
#     ├─ ca.key                 – Certificate Authority             (private)
#     ├─ kafka.keystore.key     – Broker private key (unencrypted)
#     ├─ kafka.crt              – Broker certificate signed by CA
#     ├─ kafka.keystore.pem     – kafka.crt  +  CA chain (for broker)
#     └─ kafka.truststore.pem   – ca.crt      (for clients)
#
# Usage:
#   ./generate_certs.sh [CN]
# If CN is omitted it defaults to "localhost".
#
# NOTE: script is idempotent – it refuses to overwrite existing certs.
set -euo pipefail

CN="${1:-localhost}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CERT_DIR="${SCRIPT_DIR}/certs"

mkdir -p "${CERT_DIR}"

# Abort if files already exist to avoid accidentally overwriting keys
if compgen -G "${CERT_DIR}/kafka.keystore.key" >/dev/null; then
  echo "[ERROR] Certificates already exist in ${CERT_DIR}. Remove them first if you really want to regenerate." >&2
  exit 1
fi

echo "[INFO] Generating Certificate Authority (ca.key, ca.crt) …"
openssl req -x509 -newkey rsa:2048 \
  -sha256 -days 365 \
  -nodes -subj "/CN=${CN}-CA" \
  -keyout "${CERT_DIR}/ca.key" \
  -out "${CERT_DIR}/ca.crt" >/dev/null 2>&1

echo "[INFO] Generating broker key and CSR …"
openssl req -newkey rsa:2048 -nodes \
  -subj "/CN=${CN}" \
  -keyout "${CERT_DIR}/kafka.keystore.key" \
  -out "${CERT_DIR}/kafka.csr" >/dev/null 2>&1

echo "[INFO] Signing broker certificate with CA …"
openssl x509 -req -in "${CERT_DIR}/kafka.csr" \
  -CA "${CERT_DIR}/ca.crt" -CAkey "${CERT_DIR}/ca.key" -CAcreateserial \
  -sha256 -days 365 -out "${CERT_DIR}/kafka.crt" >/dev/null 2>&1

# Build PEM bundle files expected by the Bitnami image
cat "${CERT_DIR}/kafka.crt" "${CERT_DIR}/ca.crt" > "${CERT_DIR}/kafka.keystore.pem"
cp  "${CERT_DIR}/ca.crt" "${CERT_DIR}/kafka.truststore.pem"

# Clean up CSR and serial file – not needed at runtime
rm -f "${CERT_DIR}/kafka.csr" "${CERT_DIR}/ca.srl"

echo "[DONE] Certificates written to ${CERT_DIR}" 