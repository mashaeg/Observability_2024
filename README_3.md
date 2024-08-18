# Alertmanager Configuration for Telegram Notifications

This guide explains how to configure Alertmanager to send alerts to different Telegram chats based on their severity (`critical` and `warning`).

## Prerequisites

1. **Telegram Bot**: You need a Telegram bot. If you don't have one, create it using [BotFather](https://t.me/BotFather) on Telegram.
2. **Bot Token**: Obtain the bot token from BotFather.
3. **Chat ID**: Get the chat IDs for the Telegram chats where you want to send the alerts.

## Getting the Chat ID

1. Add your bot to a Telegram group or start a private chat with the bot.
2. Send a message to the bot.
3. Visit the following URL in your browser to get updates, replacing `<your_bot_token>` with your bot token:
4. Create .env file and add:
TELEGRAM_BOT_TOKEN=7066666:AA66fdfdfdf_h0lvzvds-MN
TELEGRAM_CRITICAL_CHAT_ID=41685656
TELEGRAM_WARNING_CHAT_ID=416836567


https://api.telegram.org/bot<your_bot_token>/getUpdates

4. Look for the `chat` object in the JSON response and note the `id` value. This is your chat ID.

 ```bash
 docker restart alertmanager
 ```
### Telegram tocken

https://gist.github.com/nafiesl/4ad622f344cd1dc3bb1ecbe468ff9f8a
https://api.telegram.org/bot637xxxxxx71:AAFoxxxxxn0hwA-2TVSxxxNf4c/getUpdates



