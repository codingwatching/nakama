#!/bin/bash

set -e

if [[ -z "$1" ]]; then
  echo "the first argument must be a database username"
  exit 1;
fi

if [[ -z "$NAKAMA_DB_PASSWORD" ]]; then
  if [[ -z "$2" ]]; then
    echo "the second argument must be a database password"
    exit 1;
  fi
  NAKAMA_DB_PASSWORD="$2"
  if [[ -z "$3" ]]; then
    echo "the third argument must be a database host"
    exit 1;
  fi
  DB_HOST="$3"
  ARG="$4"
else
  if [[ -z "$2" ]]; then
    echo "the second argument must be a database host"
    exit 1;
  fi
  DB_HOST="$2"
  ARG="$3"
fi

if [[ "$ARG" == "-setup" ]]; then
  source /setup.sh
  exit 0;
fi

/nakama/nakama migrate up --database.address  nakama:nakama@${DB_HOST}:5432/nakama

rm -rf /nakama-data/*

mkdir -p /nakama-data && touch /nakama-data/config.yaml

if [[ ! -z "$ARG" ]]; then
  aws s3 cp s3://$ARG/ /nakama-data/ --recursive
fi

/nakama/nakama --config /nakama-data/config.yaml --data_dir /nakama-data --runtime.path /nakama-data --database.address nakama:nakama@${DB_HOST}:5432/nakama
