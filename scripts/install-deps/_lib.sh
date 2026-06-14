#!/usr/bin/env bash
# Lógica compartilhada Linux / macOS (sourced pelos scripts do SO).
install_npm_deps() {
  local aws_region="${AWS_REGION:-us-east-1}"
  local domain="${CODEARTIFACT_DOMAIN:-goab-core}"
  local owner="${CODEARTIFACT_DOMAIN_OWNER:-905418038614}"
  local repository="${CODEARTIFACT_REPOSITORY:-goab-repo}"

  echo "===> CodeArtifact login (npm)"
  aws codeartifact login --tool npm \
    --domain "${domain}" \
    --domain-owner "${owner}" \
    --repository "${repository}" \
    --region "${aws_region}"

  local install_extra="${GOAB_INSTALL_ARGS:-}"

  if [ -f package-lock.json ]; then
    echo "===> npm ci ${install_extra}"
    # shellcheck disable=SC2086
    npm ci ${install_extra}
  else
    echo "===> package-lock.json ausente; npm install ${install_extra}"
    # shellcheck disable=SC2086
    npm install ${install_extra}
  fi

  echo "===> Dependências instaladas"
}
