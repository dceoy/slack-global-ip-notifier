#!/usr/bin/env bash

set -e

ROOT_DIR="$(dirname ${0})"
LOG_DIR="${ROOT_DIR}/log"
LATEST_GLOBAL_IP_TXT="${LOG_DIR}/latest_global_ip.txt"
GLOBAL_IP_LOG="${LOG_DIR}/global_ip.log"
NOTIFY_SH="${ROOT_DIR}/slack_notify.sh"
NOTIFICATION=0

function fetch_ip {
  ip="$(curl -s -S ${1} | grep -oe '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}')"
  [[ "${ip}" = '' ]] && return 1
  echo "${ip}"
}

while [[ -n "${1}" ]]; do
  case "${1}" in
    '-d' | '--debug' )
      set -x
      shift 1
      ;;
    '-f' | '--force' )
      NOTIFICATION=1
      shift 1
      ;;
    * )
      echo 'invalid argument' && exit 1
      ;;
  esac
done

GLOBAL_IP="$(fetch_ip httpbin.org/ip || fetch_ip inet-ip.info || fetch_ip ifconfig.me)" \
  && [[ "${GLOBAL_IP}" = '' ]] \
  && echo 'failed to fetch ip' \
  && exit 1

set -u
echo -e "[$(date)] ${GLOBAL_IP}"

[[ ${NOTIFICATION} -eq 0 ]] \
  && [[ -f "${LATEST_GLOBAL_IP_TXT}" ]] \
  && [[ "$(cat ${LATEST_GLOBAL_IP_TXT})" = ${GLOBAL_IP} ]] \
  && exit 0

echo "${GLOBAL_IP}" > "${LATEST_GLOBAL_IP_TXT}"
${NOTIFY_SH} "GLOBAL IP :\t${GLOBAL_IP}"
