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
# => ${SLACK_USERNAME}
# => ${SLACK_ICON_EMOJI}

set -u

curl -sSX POST --data-urlencode \
  "payload={'channel': '${SLACK_CHANNEL}', \
            'username': '${SLACK_USERNAME}', \
            'text': '${ARGV[*]}', \
            'icon_emoji': '${SLACK_ICON_EMOJI}'}" \
  ${SLACK_WEBHOOK_URL} > /dev/null
