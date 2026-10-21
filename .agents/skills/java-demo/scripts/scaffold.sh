#!/usr/bin/env bash
# scaffold.sh - Generate a Spring Boot project via start.spring.io
# Usage:
#   bash scaffold.sh --name order-service --package com.acme.order --java 21 \
#       --deps web,data-jpa,validation,postgresql,lombok,test [--boot 3.4.4] [--type maven-project]
set -euo pipefail

NAME=""
PACKAGE="com.example.demo"
JAVA="21"
BOOT="3.4.4"
TYPE="maven-project"
DEPS="web,data-jpa,validation,test"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --name)   NAME="$2"; shift 2 ;;
    --package) PACKAGE="$2"; shift 2 ;;
    --java)   JAVA="$2"; shift 2 ;;
    --boot)   BOOT="$2"; shift 2 ;;
    --type)   TYPE="$2"; shift 2 ;;
    --deps)   DEPS="$2"; shift 2 ;;
    -h|--help) echo "Usage: scaffold.sh --name X --package com.x.y [--java 21] [--boot 3.4.4] [--type maven-project|gradle-project] [--deps a,b,c]"; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$NAME" ]]; then
  echo "ERROR: --name is required" >&2
  exit 1
fi

GROUP="${PACKAGE%.*}"
ARTIFACT="$NAME"
OUT="${NAME}.zip"

echo ">> Scaffolding ${GROUP}:${ARTIFACT} (Java ${JAVA}, Boot ${BOOT}, ${TYPE})"
echo ">> dependencies: ${DEPS}"

curl -fsSL "https://start.spring.io/starter.zip" \
  -d "type=${TYPE}" \
  -d "javaVersion=${JAVA}" \
  -d "bootVersion=${BOOT}" \
  -d "groupId=${GROUP}" \
  -d "artifactId=${ARTIFACT}" \
  -d "dependencies=${DEPS}" \
  -o "$OUT"

if command -v unzip >/dev/null 2>&1; then
  unzip -q -o "$OUT" -d "$NAME"
  echo ">> Created ./${NAME}/"
else
  echo ">> Downloaded ${OUT} (unzip not found; extract manually)"
fi
