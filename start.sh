#!/bin/sh
set -e

OTP_DIR=/var/opentripplanner
mkdir -p "$OTP_DIR"

echo "==== START SH $(date) ===="

FORCE_REBUILD=${FORCE_REBUILD:-false}

if [ ! -f "$OTP_DIR/map.osm.pbf" ]; then
  echo "Descargando map.osm.pbf..."
  aws s3 cp "s3://$R2_BUCKET/map.osm.pbf" "$OTP_DIR/map.osm.pbf" \
    --endpoint-url="$R2_ENDPOINT"
fi

if [ ! -f "$OTP_DIR/gtfs.zip" ]; then
  echo "Descargando gtfs.zip..."
  aws s3 cp "s3://$R2_BUCKET/gtfs.zip" "$OTP_DIR/gtfs.zip" \
    --endpoint-url="$R2_ENDPOINT"
fi

if [ "$FORCE_REBUILD" = "true" ]; then
  echo "Forzando actualización de GTFS..."
  aws s3 cp "s3://$R2_BUCKET/gtfs.zip" "$OTP_DIR/gtfs.zip" \
    --endpoint-url="$R2_ENDPOINT"

  echo "Eliminando graph.obj anterior..."
  rm -f "$OTP_DIR/graph.obj"
fi

if [ ! -f "$OTP_DIR/graph.obj" ]; then
  echo "Construyendo graph.obj..."
  java $JAVA_BUILD_OPTS -jar /app/otp.jar --build --save "$OTP_DIR"
fi

echo "Iniciando OTP..."
exec java $JAVA_SERVE_OPTS -jar /app/otp.jar --load "$OTP_DIR" --serve