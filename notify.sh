#!/usr/bin/env bash
#
# Usage:
#   ./notify.sh [-f|--force] [-q|--quiet]
#   ./notify.sh -h|--help
#
# Options:
#   -q, --quiet   Suppress messages
#   -f, --force   Force nortification
#   -h, --help    Print usage

set -ue

SCRIPT_PATH=$(realpath "${0}")
ROOT_DIR=$(dirname "${SCRIPT_PATH}")
SLACK_ENV_SH="${ROOT_DIR}/slack_env.sh"
LATEST_GLOBAL_IP_TXT="${ROOT_DIR}/.latest_global_ip.txt"
FORCE=0
QUIET=0

function print_usage {
  sed -ne '1,2d; /^#/!q; s/^#$/# /; s/^# //p;' "${SCRIPT_PATH}"
}

function abort {
  {
    if [[ ${#} -eq 0 ]]; then
      cat -
    else
      echo "${SCRIPT_PATH}: ${*}"
    fi
  } >&2
  exit 1
}

function fetch_ip {
  ip=$(curl -sS "${1}" | grep -oe '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}')
  [[ -z "${ip}" ]] && return 1
  echo "${ip}" | tail -1
}

function slack_notify {
  curl -sSX POST --data-urlencode \
    "payload={'channel': '${SLACK_CHANNEL}', \
              'username': '${SLACK_USERNAME}', \
              'text': '${*}', \
              'icon_emoji': '${SLACK_ICON_EMOJI}', \
              'icon_url': '${SLACK_ICON_URL}'}" \
    "${SLACK_WEBHOOK_URL}" > /dev/null
}

if [[ -f "${SLACK_ENV_SH}" ]]; then
  # shellcheck disable=SC1090
  source "${SLACK_ENV_SH}"
  # => SLACK_CHANNEL, SLACK_WEBHOOK_URL, SLACK_USERNAME, SLACK_ICON_EMOJI
else
  abort "${SLACK_ENV_SH} not found"
fi

while [[ ${#} -ge 1 ]]; do
  case "${1}" in
    '-d' | '--debug' )
      set -x && shift 1
      ;;
    '-f' | '--force' )
      FORCE=1 && shift 1
      ;;
    '-q' | '--quiet' )
      QUIET=1 && shift 1
      ;;
    '-h' | '--help' )
      print_usage && exit 0
      ;;
    * )
      echo 'invalid argument' && exit 1
      ;;
  esac
done

GLOBAL_IP="$(fetch_ip httpbin.org/ip || fetch_ip inet-ip.info || fetch_ip ifconfig.me)"
[[ -z "${GLOBAL_IP}" ]] && abort 'failed to fetch ip'

MESSAGE="GLOBAL IP :\t${GLOBAL_IP}"
[[ ${QUIET} -eq 0 ]] && echo -e "${MESSAGE}"

[[ ${FORCE} -eq 0 ]] \
  && [[ -f "${LATEST_GLOBAL_IP_TXT}" ]] \
  && [[ $(cat "${LATEST_GLOBAL_IP_TXT}") = "${GLOBAL_IP}" ]] \
  && exit 0

echo "${GLOBAL_IP}" > "${LATEST_GLOBAL_IP_TXT}"
slack_notify "${MESSAGE}"
