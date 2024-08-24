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

## Alertmanager uses Go templating to format alert notifications sent to different receivers like email, Slack, or Telegram. By default, Alertmanager has a set of templates that it uses for these notifications. However, you can override these default templates to customize how alerts are presented based on your needs.

Create a file (e.g., custom.tmpl) where you define your custom templates and Reference the Custom Template in Your alertmanager.yml

-telegram.default.message is the name of the template you can reference later.
-This template uses various .CommonLabels and .Annotations from the alert to build a structured message.
-The message field under telegram_configs uses the custom template defined earlier (telegram.default.message).
-The templates section at the bottom tells Alertmanager where to find the custom template file.

## Alert Testing  -   SWITCH ON expr: vector(1) for alert.rules
Slack: After one minute, this alert should fire and be routed to Slack because it has a severity: warning label.
Telegram: It should not receive this alert because Telegram is only configured to receive severity: critical alerts.

TestCriticalAlert Alert: This synthetic alert triggers immediately and is used to test the critical severity configuration for Telegram.
TestWarningAlert Alert: This synthetic alert also triggers immediately but is labeled as a warning severity and will be sent to Slack.

The or function in the template is used as a fallback mechanism to ensure that the message still displays useful information even if certain fields are missing or empty. Here's a breakdown:
How the or Function Works:

    {{ or .CommonLabels.alertname "N/A" }}: This line means:
        If .CommonLabels.alertname exists and has a value, use it.
        If .CommonLabels.alertname is missing or empty, use "N/A" instead