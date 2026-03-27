#!/bin/sh
set -e

OTP_DIR=/var/opentripplanner
mkdir -p "$OTP_DIR"

echo "==== START SH $(date) ===="

FORCE_REDOWNLOAD_GRAPH=${FORCE_REDOWNLOAD_GRAPH:-false}
JAVA_SERVE_OPTS=${JAVA_SERVE_OPTS:-"-Xms4G -Xmx6G"}

if [ "$FORCE_REDOWNLOAD_GRAPH" = "true" ]; then
  echo "Forzando re-descarga de graph.obj..."
  rm -f "$OTP_DIR/graph.obj"
fi

if [ ! -f "$OTP_DIR/graph.obj" ]; then
  echo "Descargando graph.obj..."
  aws s3 cp "s3://$R2_BUCKET/graph.obj" "$OTP_DIR/graph.obj" \
    --endpoint-url="$R2_ENDPOINT"
fi

if [ ! -f "$OTP_DIR/graph.obj" ]; then
  echo "ERROR: no se pudo descargar graph.obj"
  exit 1
fi

ls -lh "$OTP_DIR/graph.obj"

echo "Iniciando OTP..."
exec java $JAVA_SERVE_OPTS -jar /app/otp.jar --load "$OTP_DIR" --serve
