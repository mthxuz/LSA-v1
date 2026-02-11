#!/usr/bin/env bash
set -euo pipefail

PORTAINER_PORT="9443"
PORTAINER_IMAGE="portainer/portainer-ce:latest"
PORTAINER_NAME="portainer"
PORTAINER_VOLUME="portainer_data"

usage() {
  cat <<EOF
Uso: sudo ./bootstrap.sh [opções]

Opções:
  --portainer-port <porta>   Porta HTTPS do Portainer (padrão: 9443)
  -h, --help                 Mostrar ajuda

Exemplos:
  sudo ./bootstrap.sh
  sudo ./bootstrap.sh --portainer-port 9443
  sudo ./bootstrap.sh --portainer-port 9444
EOF
}

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --portainer-port)
      PORTAINER_PORT="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Argumento desconhecido: $1"
      usage
      exit 1
      ;;
  esac
done

if [[ "${EUID}" -ne 0 ]]; then
  echo "Execute como root (ou: sudo bash $0 ...)"
  exit 1
fi

log() { echo -e "\n==> $*"; }
need() { command -v "$1" >/dev/null 2>&1 || { echo "Faltando dependência: $1"; exit 1; }; }

validate_port() {
  if ! [[ "${PORTAINER_PORT}" =~ ^[0-9]+$ ]] || ((PORTAINER_PORT < 1 || PORTAINER_PORT > 65535)); then
    echo "Porta inválida: ${PORTAINER_PORT} (use 1-65535)"
    exit 1
  fi
}

install_docker_debian() {
  log "Instalando Docker (Debian/Ubuntu)"
  apt-get update -y
  apt-get install -y ca-certificates curl gnupg lsb-release

  install -m 0755 -d /etc/apt/keyrings

  . /etc/os-release
  if [[ "${ID}" == "ubuntu" ]]; then
    DOCKER_URL="https://download.docker.com/linux/ubuntu"
  else
    DOCKER_URL="https://download.docker.com/linux/debian"
  fi

  curl -fsSL "${DOCKER_URL}/gpg" | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg

  ARCH="$(dpkg --print-architecture)"
  CODENAME="$(. /etc/os-release && echo "${VERSION_CODENAME}")"

  echo "deb [arch=${ARCH} signed-by=/etc/apt/keyrings/docker.gpg] ${DOCKER_URL} ${CODENAME} stable" \
    > /etc/apt/sources.list.d/docker.list

  apt-get update -y
  apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  systemctl enable --now docker
}

install_docker_rhel() {
  log "Instalando Docker (RHEL/CentOS/Rocky/Alma)"
  need dnf
  dnf -y install dnf-plugins-core curl
  dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
  dnf -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  systemctl enable --now docker
}

setup_docker_user() {
  local target_user="${SUDO_USER:-}"
  if [[ -n "${target_user}" && "${target_user}" != "root" ]]; then
    log "Habilitando docker sem sudo para: ${target_user}"
    usermod -aG docker "${target_user}" || true
    echo "⚠️  Logout/login para aplicar grupo docker (ou: newgrp docker)."
  fi
}

deploy_portainer() {
  log "Subindo Portainer na porta ${PORTAINER_PORT} (HTTPS)"

  docker volume inspect "${PORTAINER_VOLUME}" >/dev/null 2>&1 || docker volume create "${PORTAINER_VOLUME}" >/dev/null

  if docker ps -a --format '{{.Names}}' | grep -qx "${PORTAINER_NAME}"; then
    log "Portainer já existe. Recriando para garantir portas corretas..."
    docker rm -f "${PORTAINER_NAME}" >/dev/null || true
  fi

  docker run -d \
    --name "${PORTAINER_NAME}" \
    --restart=always \
    -p 8000:8000 \
    -p "${PORTAINER_PORT}:9443" \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v "${PORTAINER_VOLUME}:/data" \
    "${PORTAINER_IMAGE}"

  log "Portainer OK. Acesse: https://SEU_IP:${PORTAINER_PORT}"
}

post_checks() {
  log "Validações"
  docker --version
  docker compose version
  docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
}

main() {
  validate_port
  need curl
  need systemctl

  if [[ -f /etc/os-release ]]; then
    . /etc/os-release
  else
    echo "Não foi possível detectar a distro (/etc/os-release ausente)."
    exit 1
  fi

  case "${ID_LIKE:-$ID}" in
    *debian*|*ubuntu*)
      install_docker_debian
      ;;
    *rhel*|*fedora*|*centos*)
      install_docker_rhel
      ;;
    *)
      echo "Distro não suportada automaticamente: ID=${ID} ID_LIKE=${ID_LIKE:-}"
      exit 1
      ;;
  esac

  setup_docker_user
  deploy_portainer
  post_checks

  log "Concluído ✅"
}

main "$@"
