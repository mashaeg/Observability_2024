#!/bin/bash

# Hardcoded bot token
apiToken="XXXXX:XXXXXXX"

# Zabbix will pass chat ID and message as $1 and $2
chatId="$1"        # Chat ID (first parameter from Zabbix)
message="$2"       # Message text (second parameter from Zabbix)

# Send the message via Telegram API
curl -s --max-time 10 -d "chat_id=$chatId&disable_web_page_preview=1&text=$message" \
"https://api.telegram.org/bot$apiToken/sendMessage" > /dev/null
