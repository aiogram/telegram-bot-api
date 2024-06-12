#!/bin/sh
set -e

USERNAME=telegram-bot-api
GROUPNAME=telegram-bot-api

chown ${USERNAME}:${GROUPNAME} "${TELEGRAM_WORK_DIR}"

if [ -n "${1}" ]; then
  exec "${*}"
fi

DEFAULT_ARGS="--dir=${TELEGRAM_WORK_DIR} --temp-dir=${TELEGRAM_TEMP_DIR} --username=${USERNAME} --groupname=${GROUPNAME}"
CUSTOM_ARGS=""

if [ -n "$TELEGRAM_LOG_FILE" ]; then
  CUSTOM_ARGS=" --log=${TELEGRAM_LOG_FILE}"
fi
if [ -n "$TELEGRAM_STAT" ]; then
  CUSTOM_ARGS="${CUSTOM_ARGS} --http-stat-port=8082"
fi
if [ -n "$TELEGRAM_FILTER" ]; then
  CUSTOM_ARGS="${CUSTOM_ARGS} --filter=$TELEGRAM_FILTER"
fi
if [ -n "$TELEGRAM_MAX_WEBHOOK_CONNECTIONS" ]; then
  CUSTOM_ARGS="${CUSTOM_ARGS} --max-webhook-connections=$TELEGRAM_MAX_WEBHOOK_CONNECTIONS"
fi
if [ -n "$TELEGRAM_VERBOSITY" ]; then
  CUSTOM_ARGS="${CUSTOM_ARGS} --verbosity=$TELEGRAM_VERBOSITY"
fi
if [ -n "$TELEGRAM_MAX_CONNECTIONS" ]; then
  CUSTOM_ARGS="${CUSTOM_ARGS} --max-connections=$TELEGRAM_MAX_CONNECTIONS"
fi
if [ -n "$TELEGRAM_PROXY" ]; then
  CUSTOM_ARGS="${CUSTOM_ARGS} --proxy=$TELEGRAM_PROXY"
fi
if [ -n "$TELEGRAM_LOCAL" ]; then
  CUSTOM_ARGS="${CUSTOM_ARGS} --local"
fi
if [ -n "$TELEGRAM_HTTP_IP_ADDRESS" ]; then
  CUSTOM_ARGS="${CUSTOM_ARGS} --http-ip-address=$TELEGRAM_HTTP_IP_ADDRESS"
fi

# Set http-port arg
if [ -n "$TELEGRAM_HTTP_PORT" ]; then
  CUSTOM_ARGS="${CUSTOM_ARGS} --http-port=$TELEGRAM_HTTP_PORT"
else
  CUSTOM_ARGS="${CUSTOM_ARGS} --http-port=8081"
fi

COMMAND="telegram-bot-api ${DEFAULT_ARGS}${CUSTOM_ARGS}"

echo "$COMMAND"
# shellcheck disable=SC2086
exec $COMMAND
