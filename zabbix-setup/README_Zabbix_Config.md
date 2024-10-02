# Zabbix Setup Manual with Telegram Notifications

## Overview
This document outlines how to set up Zabbix, create Low-Level Discovery (LLD) rules, configure triggers and notifications, including sending alerts to a Telegram channel.

---

### 1. Zabbix Agent and Server Configuration

#### 1.1 Zabbix Agent Setup (Host-A)
- Ensure that Zabbix Agent is installed on the host.
- Agent configuration is typically located at `/etc/zabbix/zabbix_agentd.conf`.
- To configure Zabbix agent to run a custom script, add:
  ```
  UserParameter=otus_important_metrics[*],/usr/local/test.sh
  ```
- Ensure that `test.sh` is executable and outputs metrics in the format:
  ```
  Host-A otus_important_metrics[metric1] 13
  Host-A otus_important_metrics[metric2] 28
  Host-A otus_important_metrics[metric3] 17
  ```

#### 1.2 Zabbix Server Configuration (Zabbix-Server)
- Make sure Zabbix server can communicate with the agent on port 10050.
- The server should listen on port 10051 for receiving data from agents.

#### 1.3 Setting Up a Cron Job
- To ensure that metrics are continuously sent to Zabbix, configure a cron job:
  ```
  * * * * * /usr/local/test.sh
  ```

#### Permissions for files:
```
sudo touch /usr/local/zdata.txt
sudo chown zabbix:zabbix /usr/local/zdata.txt
sudo chmod 664 /usr/local/zdata.txt
sudo chown zabbix:zabbix /usr/local/
sudo chmod 775 /usr/local/
sudo touch /usr/local/zsender.log
sudo chown zabbix:zabbix /usr/local/zsender.log
sudo chmod 664 /usr/local/zsender.log
```

#### Summary of ports:

| Service                | Port  | Protocol | Direction | Source/Target        |
|------------------------|-------|----------|-----------|----------------------|
| Zabbix Server (default) | 10051 | TCP      | Inbound   | Zabbix Server        |
| Zabbix Agent            | 10050 | TCP      | Inbound   | Zabbix Agent Host    |
| Telegram API (HTTPS)    | 443   | TCP      | Outbound  | Zabbix Server        |
| Zabbix Web UI (HTTP)    | 80    | TCP      | Inbound   | Zabbix Server        |
| Zabbix Web UI (HTTPS)   | 443   | TCP      | Inbound   | Zabbix Server        |

---

### 2. Telegram Notification Configuration

#### 2.1 Setup Telegram Bot
- Create a Telegram bot using `@BotFather`.
- Save the **bot token** provided by `@BotFather`.
- Start new bot
- Use the following API to get the chat ID by sending a message to your bot:
  ```
  https://api.telegram.org/bot<your-bot-token>/getUpdates
  ```
- Use the `chat_id` from the response.

#### 2.2 Zabbix Media Type Configuration
- Go to **Administration > Media Types** in the Zabbix Web UI.
- Create a new media type using the following settings:
  - **Type**: Script
  - **Script name**: `telegram.sh`
  - **Script parameters**: `{ALERT.SENDTO}`, `{ALERT.MESSAGE}`

#### 2.3 Create `telegram.sh` Script
Create the `telegram.sh` script in `/usr/lib/zabbix/alertscripts/` with the following content:

```bash
#!/bin/bash

chatId="$1"  # First parameter: chat ID
message="$2" # Second parameter: message text
apiToken="YOUR_BOT_TOKEN" # Replace with your Telegram bot token

curl -s --max-time 10 -d "chat_id=$chatId&disable_web_page_preview=1&text=$message" "https://api.telegram.org/bot$apiToken/sendMessage" > /dev/null
```
- Ensure the script is executable:
  ```bash
  sudo chmod +x /usr/lib/zabbix/alertscripts/telegram.sh
  ```

---

### 3. LLD and Trigger Setup

#### 3.0 Create Templae
Template name: otus_lld
Template groups: Templates/Operating systems

#### 3.1 Create disovery rule
Create LLD rules to discover custom metrics on the new template:
- Select **Discovery rules** and create a new rule:
  - **Name**: otus.discovery
  - **Key**: otus.discovery
  - **Type**: Zabbix agent
  - **Update interval**: 1m

#### 3.2 Create new Prototypes for Items and Triggers
- Create item prototypes for discovered metrics:
  - **Name**: Number of {#METRICNAME} in stock
  - **Type**: Zabbix trapper
  - **Type of information**: Numeric (unsigned)
  - **Key**: `otus_important_metrics[{#METRICNAME}]`
- Create trigger prototypes:
  - **Name**: Number of {#METRICNAME} is too high
  - **Severity**: High
  - **Problem expression**: last(/otus_lld/otus_important_metrics[{#METRICNAME}])>95
  - **Recovery expression**: last(/otus_lld/otus_important_metrics[{#METRICNAME}])<95

#### 3.3 Add new template to Host-A

---

### 4. Custom Messages and Trigger Throttling

#### 4.1 Custom Messages for Alerts

**Problem Message (Operations)**:
```plaintext
⚠️ Problem Detected ⚠️

The metric `{ITEM.KEY}` on `{HOST.NAME}` is too high!
Current Value: `{ITEM.VALUE}`

Trigger: `{TRIGGER.NAME}`
Severity: `{TRIGGER.SEVERITY}`
Time of Problem: {EVENT.DATE} {EVENT.TIME}
```

**Recovery Message**:
```plaintext
✅ Problem Resolved ✅

The metric `{ITEM.KEY}` on `{HOST.NAME}` has returned to a normal value.
Recovered Value: `{ITEM.VALUE}`
Resolved Trigger: `{TRIGGER.NAME}`
Recovery Time: {EVENT.RECOVERY.DATE} {EVENT.RECOVERY.TIME}
```

**Update Message (Acknowledgement)**:
```plaintext
ℹ️ Update on Problem ℹ️

An update has been made to the issue: `{TRIGGER.NAME}`
Acknowledged by: `{USER.FULLNAME}`
Details: {EVENT.ACK.STATUS}
```

#### 4.2 Trigger Hysteresis to Avoid Flapping
- Modify the trigger expression to avoid frequent notifications:
  - Problem threshold: >95
  - Recovery threshold: <90

Example:
```plaintext
{host:otus_important_metrics[{#METRICNAME}].last()}>95 and {host:otus_important_metrics[{#METRICNAME}].last()}<90
```

---

### 5. Debugging

#### 5.1 Common Issues
- **Database Connection Errors**: Ensure MySQL is running and has available resources (`sudo systemctl start mysql`).
- **Permission Issues**: Check file permissions for scripts (`chmod +x /usr/lib/zabbix/alertscripts/telegram.sh`).
- **Script Execution Issues**: Check logs (`/var/log/zabbix/zabbix_server.log`) for detailed error messages.

---

### 6. Conclusion
This manual provides detailed steps to set up Zabbix, configure LLD rules, create custom triggers, and integrate Telegram for alert notifications. Additionally, steps to avoid frequent triggers and customize messages were covered.
