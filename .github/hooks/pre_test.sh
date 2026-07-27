#!/usr/bin/env bash
set -euo pipefail

source /workspace/.ci-workflows/hooks/lib/distro.sh
source /workspace/.ci-workflows/hooks/lib/common.sh || true

log "Project pre-test hook – distro: $ID ($ID_LIKE)"

echo "[DEBUG] /etc/os-release content:"
cat /etc/os-release || true
echo "[DEBUG] Detected ID=$ID, ID_LIKE=$ID_LIKE, RELEASE=${RELEASE:-unknown}"

fail_unsupported() {
  echo "[ERROR] $*" >&2
  exit 1
}

if is_el; then
  log "RHEL-kompatible Distro erkannt – installiere OpenVox..."

  case "${RELEASE}" in
    8|9|10) ;;
    *)
      fail_unsupported "OpenVox 8 Release-Paket fuer EL ${RELEASE} ist nicht in der Allowlist. Unterstuetzte EL-Versionen: 8, 9, 10."
      ;;
  esac

  release_url="https://yum.voxpupuli.org/openvox8-release-el-${RELEASE}.noarch.rpm"

  dnf install -y --allowerasing ca-certificates curl
  if ! curl -fsSI "${release_url}" >/dev/null; then
    fail_unsupported "Release-Paket nicht erreichbar: ${release_url}."
  fi

  dnf install -y --allowerasing "${release_url}"
  dnf makecache
elif is_debian || is_ubuntu; then
  log "Debian/Ubuntu erkannt - installiere OpenVox 8 APT Repository..."

  if is_debian; then
    case "${RELEASE}" in
      10|11|12|13) ;;
      *)
        fail_unsupported "OpenVox 8 Release-Paket fuer Debian ${RELEASE} ist nicht in der Allowlist. Unterstuetzte Debian-Versionen: 10, 11, 12, 13."
        ;;
    esac
    release_pkg="openvox8-release-debian${RELEASE}.deb"
  else
    case "${VERSION_ID}" in
      18.04|20.04|22.04|24.04|25.04|26.04) ;;
      *)
        fail_unsupported "OpenVox 8 Release-Paket fuer Ubuntu ${VERSION_ID} ist nicht in der Allowlist. Unterstuetzte Ubuntu-Versionen: 18.04, 20.04, 22.04, 24.04, 25.04, 26.04."
        ;;
    esac
    release_pkg="openvox8-release-ubuntu${VERSION_ID}.deb"
  fi

  release_url="https://apt.voxpupuli.org/${release_pkg}"
  log "Installing release package: ${release_url}"

  apt-get update -y
  apt-get install -y --no-install-recommends ca-certificates curl

  if ! curl -fsSI "${release_url}" >/dev/null; then
    fail_unsupported "Release-Paket nicht erreichbar: ${release_url}."
  fi

  curl -fL --retry 3 -o "/tmp/${release_pkg}" "${release_url}"
  apt-get install -y "/tmp/${release_pkg}"
  apt-get update -y
else
  log "Nicht-RHEL-kompatible Distribution – epel-release wird übersprungen."
fi
