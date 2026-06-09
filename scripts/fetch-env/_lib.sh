#!/usr/bin/env bash
# Busca JSON no AWS Secrets Manager e grava .env (Linux / macOS).

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "❌ Comando obrigatório ausente: $1" >&2
    exit 1
  fi
}

resolve_secret_id() {
  local root="$1"
  if [ -n "${GOAB_AWS_SECRET_ID:-}" ]; then
    printf '%s' "${GOAB_AWS_SECRET_ID}"
    return
  fi
  if [ -f "${root}/.goab-aws-secret-id" ]; then
    tr -d ' \n\r' < "${root}/.goab-aws-secret-id"
    return
  fi
  printf 'dev/%s' "$(basename "${root}")"
}

format_env_line() {
  local key="$1"
  local value="$2"
  # JSON em uma linha (ex.: GOOGLE_CREDENTIALS) — valor puro, sem aspas nem \"
  if [[ "${value}" =~ ^[[:space:]]*[\{\[] ]]; then
    printf '%s=%s\n' "${key}" "${value}"
    return
  fi
  if [[ "${value}" == *$'\n'* || "${value}" == *'"'* || "${value}" == *'#'* ]]; then
    local escaped="${value//\\/\\\\}"
    escaped="${escaped//\"/\\\"}"
    printf '%s="%s"\n' "${key}" "${escaped}"
  else
    printf '%s=%s\n' "${key}" "${value}"
  fi
}

fetch_env_from_secrets_manager() {
  local root="$1"
  local region="${AWS_REGION:-us-east-1}"
  local env_file="${GOAB_ENV_FILE:-.env}"
  local secret_id
  secret_id="$(resolve_secret_id "${root}")"

  require_cmd aws
  require_cmd jq

  echo "===> AWS Secrets Manager"
  echo "     secret-id: ${secret_id}"
  echo "     region:    ${region}"

  local err_file secrets aws_status
  err_file="$(mktemp)"
  # set -e no linux.sh/darwin.sh abortaria aqui antes de tratar secret ausente
  set +e
  secrets="$(
    aws secretsmanager get-secret-value \
      --secret-id "${secret_id}" \
      --region "${region}" \
      --query SecretString \
      --output text 2>"${err_file}"
  )"
  aws_status=$?
  set -e
  if [ "${aws_status}" -ne 0 ]; then
    local err
    err="$(cat "${err_file}")"
    rm -f "${err_file}"
    if echo "${err}" | grep -qiE 'ResourceNotFoundException|ResourceNotFound|SecretNotFound|can.t find|not find the specified secret'; then
      echo "⏭️  Secret não encontrado (${secret_id}) — .env não alterado"
      echo "GOAB_FETCH_ENV_STATUS=skipped"
      exit 0
    fi
    echo "❌ Falha ao ler secret (${secret_id}):" >&2
    echo "${err}" >&2
    exit 1
  fi
  rm -f "${err_file}"

  if [ -z "${secrets}" ] || [ "${secrets}" = "null" ]; then
    echo "❌ Secret vazio: ${secret_id}" >&2
    exit 1
  fi

  if ! echo "${secrets}" | jq -e 'type == "object"' >/dev/null 2>&1; then
    echo "❌ Secret deve ser JSON objeto (chave → valor)." >&2
    exit 1
  fi

  local dest="${root}/${env_file}"

  {
    echo "# Gerado por scripts/fetch-env ($(date -u +%Y-%m-%dT%H:%M:%SZ))"
    echo "# secret-id: ${secret_id}"
    echo ""
    while IFS= read -r line; do
      [ -n "${line}" ] || continue
      local k="${line%%=*}"
      local v="${line#*=}"
      format_env_line "${k}" "${v}"
    done < <(
      echo "${secrets}" | jq -r '
        to_entries[]
        | select(.value != null and (.value | tostring) != "")
        | .key as $k | .value as $v
        | if ($v | type) == "object" or ($v | type) == "array" then
            "\($k)=\($v | tojson)"
          elif ($v | type) == "string" then
            (try ($v | fromjson) catch $v) as $parsed
            | if ($parsed | type) == "object" or ($parsed | type) == "array" then
                "\($k)=\($parsed | tojson)"
              else
                "\($k)=\($parsed)"
              end
          else
            "\($k)=\($v | tostring)"
          end
      '
    )
  } > "${dest}"

  local keys skipped
  keys="$(grep -E '^[A-Za-z_][A-Za-z0-9_]*=' "${dest}" | cut -d= -f1 | paste -sd, -)"
  skipped="$(
    echo "${secrets}" | jq -r --arg written "${keys}" '
      [keys[] | select(($written | split(",") | index(.) | not))]
      | if length > 0 then join(", ") else empty end
    '
  )"
  echo "===> ${dest} atualizado"
  echo "===> Chaves gravadas: ${keys}"
  if [ -n "${skipped}" ]; then
    echo "===> Omitidas (vazio no secret): ${skipped}"
  fi
}
