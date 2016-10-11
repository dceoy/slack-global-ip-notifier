#!/usr/bin/env bash

set -e

if [[ "${1}" = '--debug' ]]; then
  set -x
  shift 1
fi

ARGV="${*}"
source "$(dirname ${0})/slack_env.sh"
# => ${SLACK_CHANNEL}
# => ${SLACK_WEBHOOK_URL}

set -u

SLACK_USERNAME="$(whoami)@$(hostname)"
HOUR=$(( $(date '+%H') % 12 ))
SLACK_ICON_EMOJI=":clock$([[ ${HOUR} -eq 0 ]] && echo 12 || echo ${HOUR}):"

curl -sSX POST --data-urlencode \
  "payload={'channel': '${SLACK_CHANNEL}', \
            'username': '${SLACK_USERNAME}', \
            'text': '${ARGV[*]}', \
            'icon_emoji': '${SLACK_ICON_EMOJI}'}" \
  ${SLACK_WEBHOOK_URL} > /dev/null
