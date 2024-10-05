## Connect to InfluxDB from Chronograf Using Token

1. **Open Chronograf** in your web browser (typically available at [http://localhost:8888](http://localhost:8888)). Depending on your setup, the address may vary, so adjust it accordingly.

2. Look for a **configuration or settings icon** (often a gear or wrench icon) and click on it.

3. Find the **"InfluxDB Connection"** or **"Add Connection"** section.

4. Fill in the following details:

   - **Connection URL:** `http://influxdb:8086`
   - **Connection Name:** `InfluxDB`
   - **Organization:** `my_org`
   - **Token:** `6zlwmexm0mcFOh2Xz_P41tx9RYCZCbkVb52xgtP360b-9IJeCxevBWmMlJ89chK5NiLRSDpft9LzKay96tUCmA==`
   - **Default Bucket:** `my_bucket`
   - **Telegraf Database Name:** `telegraf`

### Notes:

- The **Connection URL** uses `influxdb` as the hostname because it's the service name in your Docker network. If you're connecting from outside the Docker network, use the appropriate IP or hostname.
- The **Organization** and **Default Bucket** should match what you've set in your `.env` file and InfluxDB configuration.
- The **Token** is the one provided in your `.env` file.
- The **Telegraf Database Name** is typically `telegraf` unless you've specified otherwise.

5. After filling in these details, click **"Add Connection"** or **"Save Changes"**.

Chronograf should now attempt to connect to InfluxDB. If successful, you should see a green checkmark or a success message.

---

## After Setting up the Connection:

1. Navigate to the **"Host List"** or **"Infrastructure"** page in Chronograf.
   
   - You should see a list of hosts that Telegraf is monitoring.

2. If you're **not seeing any hosts**:

   - **Check the Chronograf logs**: 
     ```bash
     docker-compose logs chronograf
     ```

   - **Verify data in InfluxDB directly** using the CLI:
   
     Access the InfluxDB container:
     ```bash
     docker exec -it influxdb /bin/bash
     ```
     Run the following query:
     ```bash
     influx query 'from(bucket:"my_bucket") |> range(start: -1h) |> filter(fn: (r) => r._measurement == "cpu") |> limit(n:5)'
     ```
   
     Replace `"my_bucket"` with your actual bucket name to match your setup.
