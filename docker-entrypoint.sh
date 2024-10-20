#!/usr/bin/env sh
set -e

USERNAME="telegram-bot-api"
GROUPNAME="telegram-bot-api"

COMMAND="telegram-bot-api"

# Appends an argument to the COMMAND variable.
append_args() {
  COMMAND="$COMMAND $1"
}

# Sets $env_var from $file_env_var content or directly from $env_var.
# Usage: file_env <env_var> <file_env_var>
# - If both or neither variables are set, exits with an error.
# - If only $file_env_var is set, reads content from the file path and sets $env_var.
# - Exits with an error if the file does not exist.
file_env() {
    env_var="$1"
    file_env_var="$2"
    env_value=$(printenv "$env_var") || env_value=""
    file_path=$(printenv "$file_env_var") || file_path=""

    if [ -z "$env_value" ] && [ -z "$file_path" ]; then
        echo "error: expected $env_var or $file_env_var env vars to be set"
        exit 1
    elif [ -n "$env_value" ] && [ -n "$file_path" ]; then
        echo "both $env_var and $file_env_var env vars are set, expected only one of them"
        exit 1
    elif [ -n "$file_path" ]; then
        if [ -f "$file_path" ]; then
            export "$env_var=$(cat "$file_path")"
        else
            echo "error: $env_var=$file_path: file '$file_path' does not exist"
            exit 1
        fi
    fi
}

# Checks if an environment variable is set.
# Usage: check_required_env <var_name>
# - Exits with an error if the variable is not set.
check_required_env() {
  var_name="$1"

  if [ -z "$(printenv "$var_name")" ]; then
    echo "error: environment variable $var_name is required"
    exit 1
  fi
}

# Appends an argument to CUSTOM_ARGS based on the environment variable value.
# Usage: append_arg_from_env <var_name> <arg_name> <default_value>
# - If <var_name> is set, uses its value; otherwise, uses <default_value>.
# - Appends "<arg_name>=<value>" to CUSTOM_ARGS if a value is found.
append_arg_from_env() {
    var_name="$1"
    arg_name="$2"
    default_value="$3"
    env_value=$(printenv "$var_name") || env_value=""

    [ -n "$env_value" ] || env_value="$default_value"
    if [ -n "$env_value" ]; then
      append_args "${arg_name}=$env_value"
    fi
}

# Appends a flag to CUSTOM_ARGS if the environment variable is set (non-empty).
# Usage: append_flag_from_env <var_name> <flag_name>
# - If <var_name> is set, appends <flag_name> to CUSTOM_ARGS.
append_flag_from_env() {
  var_name="$1"
  flag_name="$2"

  if [ -n "$(printenv "$var_name")" ]; then
    append_args "$flag_name"
  fi
}

check_required_env "TELEGRAM_WORK_DIR"
chown "${USERNAME}:${GROUPNAME}" "${TELEGRAM_WORK_DIR}"

# Telegram Bot API Server knows how to read the API ID and API Hash from a environment variable.
# Is not needed to pass it as arguments.
file_env "TELEGRAM_API_ID" "TELEGRAM_API_ID_FILE"
file_env "TELEGRAM_API_HASH" "TELEGRAM_API_HASH_FILE"

# Default arguments, passed from the Dockerfile.
# Potentially can be overwritten by environment variables, if needed, but is not recommended.
append_arg_from_env "TELEGRAM_WORK_DIR" "--dir"
check_required_env "TELEGRAM_TEMP_DIR"
append_arg_from_env "TELEGRAM_TEMP_DIR" "--temp-dir"
append_args "--username=${USERNAME}"
append_args "--groupname=${GROUPNAME}"

check_required_env "TELEGRAM_API_ID"
check_required_env "TELEGRAM_API_HASH"

# Environment variables that can be passed as arguments from environment by administrator.
append_arg_from_env "TELEGRAM_HTTP_PORT" "--http-port" "8081"
append_flag_from_env "TELEGRAM_LOCAL" "--local"
append_flag_from_env "TELEGRAM_STAT" "--http-stat-port=8082"  # maybe change it to dynamic variable in the future
append_arg_from_env "TELEGRAM_LOG_FILE" "--log"
append_arg_from_env "TELEGRAM_FILTER" "--filter"
append_arg_from_env "TELEGRAM_MAX_WEBHOOK_CONNECTIONS" "--max-webhook-connections"
append_arg_from_env "TELEGRAM_VERBOSITY" "--verbosity"
append_arg_from_env "TELEGRAM_MAX_CONNECTIONS" "--max-connections"
append_arg_from_env "TELEGRAM_PROXY" "--proxy"
append_arg_from_env "TELEGRAM_HTTP_IP_ADDRESS" "--http-ip-address"

echo "$COMMAND"
exec $COMMAND
