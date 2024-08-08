#!/bin/sh
set -e

USERNAME=telegram-bot-api
GROUPNAME=telegram-bot-api

chown ${USERNAME}:${GROUPNAME} "${TELEGRAM_WORK_DIR}"

if [ -n "${1}" ]; then
  exec "${*}"
fi

DEFAULT_ARGS="--http-port 8081 --dir=${TELEGRAM_WORK_DIR} --temp-dir=${TELEGRAM_TEMP_DIR} --username=${USERNAME} --groupname=${GROUPNAME}"
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

COMMAND="telegram-bot-api ${DEFAULT_ARGS}${CUSTOM_ARGS}"

file_env() {
  local var_name="$1"
  local file_var_name="$2"

  var_value=$(printenv "$var_name") || var_value=""
  file_path=$(printenv "$file_var_name") || file_path=""

  if [ -z "$var_value" ] && [ -z "$file_path" ]; then
    echo "error: expected $var_name or $file_var_name env vars to be set"
    exit 1

  elif [ -n "$var_value" ] && [ -n "$file_path" ]; then
    echo "both and $var_name $file_var_name env vars are set, expected only one of them"
    exit 1

  else
    if [ -n $file_path ]; then
      if [ -f "$file_path" ]; then
        file_content=$(cat "$file_path")
        export "$var_name=$file_content"
      else
        echo "error: file '$file_path' does not exist"
        exit 1
      fi
    fi
  fi
}

file_env "TELEGRAM_API_ID" "TELEGRAM_API_ID_FILE"
file_env "TELEGRAM_API_HASH" "TELEGRAM_API_HASH_FILE"

echo "$COMMAND"
# shellcheck disable=SC2086
exec $COMMAND
