#!/bin/bash
if [ -z "$PGHOST" ]; then
  echo "[ERROR] PGHOST Env Variable can't be empty." && exit 1
fi
if [ -z "$PGPASSWORD" ]; then
  echo "[ERROR] PGPASSWORD Env Variable can't be empty." && exit 1
else
    echo "[INFO] Connection details for postgres server"
    echo "** HOST: $PGHOST **"
    echo "** PORT: $PGPORT **"
    echo "** USER: $PGUSER **"
    echo "** DATABASE: $PGDATABASE **"
fi