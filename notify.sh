#!/usr/bin/env bash

set -e

ROOT_DIR="$(dirname ${0})"
LATEST_GLOBAL_IP_TXT="${ROOT_DIR}/.latest_global_ip.txt"
FORCE=0
QUIET=0
source "${ROOT_DIR}/slack_env.sh" # => SLACK_CHANNEL, SLACK_WEBHOOK_URL, SLACK_USERNAME, SLACK_ICON_EMOJI

function fetch_ip {
  ip="$(curl -s -S ${1} | grep -oe '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}')"
  [[ "${ip}" = '' ]] && return 1
  echo "${ip}"
}

function slack_notify {
  curl -sSX POST --data-urlencode \
    "payload={'channel': '${SLACK_CHANNEL}', \
              'username': '${SLACK_USERNAME}', \
              'text': '${*}', \
              'icon_emoji': '${SLACK_ICON_EMOJI}', \
              'icon_url': '${SLACK_ICON_URL}'}" \
    ${SLACK_WEBHOOK_URL} > /dev/null
}

while [[ -n "${1}" ]]; do
  case "${1}" in
    '-d' | '--debug' )
      set -x
      shift 1
      ;;
    '-f' | '--force' )
      FORCE=1
      shift 1
      ;;
    '-q' | '--quiet' )
      QUIET=1
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
MESSAGE="GLOBAL IP :\t${GLOBAL_IP}"
[[ ${QUIET} -eq 0 ]] && echo -e "${MESSAGE}"

[[ ${FORCE} -eq 0 ]] \
  && [[ -f "${LATEST_GLOBAL_IP_TXT}" ]] \
  && [[ "$(cat ${LATEST_GLOBAL_IP_TXT})" = ${GLOBAL_IP} ]] \
  && exit 0

echo "${GLOBAL_IP}" > "${LATEST_GLOBAL_IP_TXT}"
slack_notify "${MESSAGE}"
