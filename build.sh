#!/usr/bin/env bash
set -e

odin build src -out:codedawa
./codedawa

port=8000
while lsof -i :"$port" >/dev/null 2>&1; do
  port=$((port + 1))
done

echo "Serving at http://localhost:$port"
python3 -m http.server "$port" -d Build
