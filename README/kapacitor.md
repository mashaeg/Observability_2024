# Setting Up Kapacitor Connection in Chronograf

## Connection Setup

1. Open Chronograf in your web browser (usually at `http://localhost:8888`).
2. Navigate to the Configuration or Settings page (often represented by a gear or wrench icon).
3. Look for a section called "Kapacitor Connections" or "Add Kapacitor Connection".
4. Fill in the following details:
   - Kapacitor URL: `http://kapacitor:9092`
   - Name: `Kapacitor`
   - Username: (leave blank unless you've set up authentication)
   - Password: (leave blank unless you've set up authentication)
5. Click "Add Connection" or "Save Changes".

## Notes

- The Kapacitor URL uses `kapacitor` as the hostname because that's the service name in your Docker network.
- The default Kapacitor port is 9092.
- Username and Password are typically left blank in development environments unless you've explicitly set up authentication for Kapacitor.
- Chronograf should attempt to connect to Kapacitor after saving. If successful, you should see a green checkmark or a success message.

## After Setting Up the Connection

1. Go to the "Alerting" or "Kapacitor Rules" section in Chronograf.
2. You should now be able to create and manage Kapacitor tasks and alerts through the Chronograf interface.

## Verifying Kapacitor Connection and Functionality

### Check Kapacitor Logs

Run the following command to view Kapacitor logs:

```bash
docker-compose logs kapacitor
```

### Create a Test Alert

1. In Chronograf, go to the "Alerting" section.
2. Create a simple alert, such as a threshold alert on CPU usage.
3. This will help verify that Kapacitor can receive data from InfluxDB and process it.

By following these steps, you can ensure that Kapacitor is properly connected to your system and functioning as expected.
