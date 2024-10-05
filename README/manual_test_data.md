# Guide: Writing and Verifying Test Data in InfluxDB

## 1. Writing Test Data to InfluxDB

### Ensure Your Configuration is Active

First, confirm that the onboarding configuration is correctly set and active:

```bash
influx config ls
```

You should see onboarding as the active configuration, using your 192.168.0.24 URL and your organization ID (4afd0e5e3410d10b).

### Write Test Data to InfluxDB

Use the following command to write test data to your my_bucket:

```bash
influx write \
  --bucket my_bucket \
  --org "4afd0e5e3410d10b" \
  --token "i6GA5aHLZcW6GTj7gGFuOYmtnyWdS-hVGuEguxO0GR9T2l4gmfA4wncxOWYMDJYCEx9Ajx_1U0P21i7CRgjGWw==" \
  --precision ns \
  'test_measurement,location=office temperature=22.5'
```

This command writes a point to the my_bucket with the following:
- Measurement: test_measurement
- Tag: location=office
- Field: temperature=22.5

### Verify Test Data

After writing the data, query it to ensure it was successfully written:

```bash
influx query \
  'from(bucket: "my_bucket") 
   |> range(start: -1h) 
   |> filter(fn: (r) => r._measurement == "test_measurement")'
```

This query will return the data from the test_measurement measurement written in the past hour.

### Writing Multiple Data Points

To write multiple test data points at once:

```bash
influx write \
  --bucket my_bucket \
  --org "4afd0e5e3410d10b" \
  --token "i6GA5aHLZcW6GTj7gGFuOYmtnyWdS-hVGuEguxO0GR9T2l4gmfA4wncxOWYMDJYCEx9Ajx_1U0P21i7CRgjGWw==" \
  --precision ns \
  'test_measurement,location=office temperature=22.5
   test_measurement,location=lab temperature=18.7
   test_measurement,location=server_room temperature=26.0'
```

This command writes three data points to test_measurement, each with a different location and temperature.

## 2. Confirming Data Using the InfluxDB UI

### Step 1: Access the InfluxDB UI
1. Open a browser and go to the InfluxDB web interface at http://192.168.0.24:8086.
2. Log in with your token and organization.

### Step 2: Query Data in the Data Explorer
1. In the InfluxDB UI, go to Data Explorer (usually found under Explore).
2. Select the bucket (my_bucket) from which you want to query data.
3. In the query builder:
   - Choose the measurement test_measurement.
   - Choose the fields (like temperature) and any tags (like location).
   - Click Submit to run the query and view the data.

You should see the test data you inserted (e.g., temperature readings from different locations).

## 3. Confirming Data Using Chronograf

### Step 1: Access Chronograf
1. Open Chronograf at http://192.168.0.24:8888.
2. Ensure the data source is properly connected to InfluxDB.

### Step 2: Create a Query in the Dashboard
1. Create a new dashboard or open an existing one.
2. Add a new cell to the dashboard.
3. In the Data Explorer:
   - Choose the bucket (my_bucket)
   - Select the measurement (test_measurement)
   - Choose the fields (e.g., temperature)
4. Set the time range to Last 1 hour (or adjust as needed).
5. Run the query and confirm if the test data is visible.

## Summary

- **InfluxDB CLI**: Run the query to confirm the data using `influx query`.
- **InfluxDB UI**: Use the Data Explorer in the web interface to query and view your data.
- **Chronograf**: Create or update a dashboard to visualize the data from my_bucket.

## Next Steps

1. Confirm the data is being written by running the `influx query` command to verify the data in my_bucket.
2. Visualize the data in Chronograf or any other visualization tool you're using, like Grafana, to see if the test data is available for charting.
