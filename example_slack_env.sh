SLACK_CHANNEL='#random'
SLACK_WEBHOOK_URL='https://hooks.slack.com/services/xxxxxxxxx/yyyyyyyyy/zzzzzzzzzzzzzzzzzzzzzzzz'
SLACK_USERNAME="$(whoami)@$(hostname)"
SLACK_ICON_EMOJI=":clock$(h=$(( $(date '+%H') % 12 )) && [[ ${h} -eq 0 ]] && echo 12 || echo ${h}):"
