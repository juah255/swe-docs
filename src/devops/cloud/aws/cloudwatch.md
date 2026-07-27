# Amazon CloudWatch

## What Is CloudWatch?

CloudWatch is AWS's observability service. It collects metrics, logs, and events across your AWS resources and applications.

## Metrics

Metrics are time-series data points. AWS services publish default metrics automatically.

```bash
# Get EC2 CPU utilization
aws cloudwatch get-metric-statistics \
  --namespace AWS/EC2 \
  --metric-name CPUUtilization \
  --dimensions Name=InstanceId,Value=i-0abc123 \
  --start-time 2025-01-01T00:00:00Z \
  --end-time 2025-01-01T01:00:00Z \
  --period 300 \
  --statistics Average
```

### Custom Metrics

Push your own metrics for application-specific monitoring.

```python
import boto3

cloudwatch = boto3.client('cloudwatch')
cloudwatch.put_metric_data(
    Namespace='MyApp',
    MetricData=[{
        'MetricName': 'OrdersPerMinute',
        'Dimensions': [{'Name': 'Environment', 'Value': 'prod'}],
        'Value': 42,
        'Unit': 'Count'
    }]
)
```

## Alarms

Alarms watch a metric and trigger actions when thresholds are breached.

```bash
# Alarm when CPU > 80% for 3 consecutive periods
aws cloudwatch put-metric-alarm \
  --alarm-name high-cpu \
  --metric-name CPUUtilization \
  --namespace AWS/EC2 \
  --statistic Average \
  --period 300 \
  --evaluation-periods 3 \
  --threshold 80 \
  --comparison-operator GreaterThanThreshold \
  --dimensions Name=InstanceId,Value=i-0abc123 \
  --alarm-actions arn:aws:sns:us-east-1:123456789012:my-alerts \
  --treat-missing-data missing
```

Actions can trigger SNS notifications, Auto Scaling policies, or Lambda functions.

## Logs

### Log Groups and Log Streams

- **Log Group**: A container for logs (e.g., `/aws/ec2/myapp`)
- **Log Stream**: A sequence of log events from a single source

```bash
# Create a log group
aws logs create-log-group --log-group-name /aws/ec2/myapp

# Set retention
aws logs put-retention-policy \
  --log-group-name /aws/ec2/myapp \
  --retention-in-days 30
```

### CloudWatch Agent

Collects system metrics and logs from EC2 instances and on-premises servers.

```json
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/syslog",
            "log_group_name": "/var/log/syslog",
            "log_stream_name": "{instance_id}"
          }
        ]
      }
    }
  },
  "metrics": {
    "namespace": "CustomSystemMetrics",
    "metrics_collected": {
      "disk": { "measurement": ["used_percent"] },
      "mem": { "measurement": ["mem_used_percent"] }
    }
  }
}
```

```bash
# Start the agent
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config -m ec2 \
  -s -c file:/opt/aws/amazon-cloudwatch-agent/etc/config.json
```

## Dashboards

Combine metrics from multiple services into a single view.

```bash
# Create a dashboard
aws cloudwatch put-dashboard \
  --dashboard-name MyDashboard \
  --dashboard-body '{
    "widgets": [{
      "type": "metric",
      "properties": {
        "metrics": [
          ["AWS/EC2", "CPUUtilization", { "stat": "Average" }]
        ],
        "period": 300,
        "title": "EC2 CPU"
      }
    }]
  }'
```

## Billing Alerts

Get notified when your estimated charges exceed a threshold.

```bash
# Enable billing alerts (one-time, in the billing console)
# Then create an alarm on the estimated charges metric
aws cloudwatch put-metric-alarm \
  --alarm-name billing-alert-100 \
  --namespace AWS/Billing \
  --metric-name EstimatedCharges \
  --statistic Maximum \
  --period 21600 \
  --evaluation-periods 1 \
  --threshold 100 \
  --comparison-operator GreaterThanThreshold \
  --alarm-actions arn:aws:sns:us-east-1:123456789012:billing-alerts
```

---

## Interview Q&A

**Q1: What is the difference between CloudWatch Logs Insights and Metric Filters?**
Metric Filters scan log data in real-time and extract metrics that you can graph and alarm on. CloudWatch Logs Insights is an interactive query language (similar to Splunk) for ad-hoc searching and analyzing log data. Metric Filters are for continuous monitoring; Logs Insights is for investigation and troubleshooting.

**Q2: How would you set up a billing alert to avoid surprise charges?**
Enable billing alerts in the AWS account settings (required once). Then create a CloudWatch alarm on the `AWS/Billing` - `EstimatedCharges` metric. Set the threshold (e.g., $100), the evaluation period, and configure an SNS topic as the alarm action. Subscribe your email or Slack webhook to the SNS topic. You can create multiple alarms at different thresholds (e.g., $50 warning, $100 critical).
