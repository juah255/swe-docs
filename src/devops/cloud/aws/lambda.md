# AWS Lambda

## What Is Lambda?

Lambda runs code without provisioning servers. Upload your function, configure a trigger, and Lambda executes it on demand. You pay only for compute time used.

## Event Triggers

| Trigger | Source |
|---------|--------|
| API Gateway | HTTP/REST requests |
| S3 | Object create/delete events |
| DynamoDB Streams | Table changes |
| SQS | Message arrival |
| EventBridge | Scheduled rules, events |
| SNS | Message notifications |
| IoT | Device messages |
| CloudFront | Lambda@Edge for CDN |

```python
def handler(event, context):
    print(f"Event: {event}")
    return {
        'statusCode': 200,
        'body': 'Hello from Lambda'
    }
```

## Cold Starts

The first invocation after idle time incurs a cold start — Lambda provisions a microVM, downloads your code, and initializes the runtime.

| Language | Typical Cold Start |
|----------|--------------------|
| Python / Node.js | 100–300 ms |
| Java / .NET | 500–2000 ms |
| Custom runtime | Depends on package size |

Mitigations:
- **Provisioned Concurrency**: Keep N instances warm (costs money)
- **SnapStart** (Java): Snapshot the initialized state
- Reduce deployment package size
- Avoid VPC-attached functions (improved since 2019, but still adds latency)

## Limits

| Limit | Value |
|-------|-------|
| Memory | 128 MB – 10 GB |
| Timeout | 15 minutes |
| Payload (sync) | 6 MB |
| Payload (async) | 256 KB |
| Ephemeral storage | 512 MB (configurable up to 10 GB) |
| Concurrent executions | 1000 (soft limit, adjustable) |
| Package size (zipped) | 50 MB |
| Package size (unzipped) | 250 MB |

## Lambda vs ECS vs EC2

| Factor | Lambda | ECS | EC2 |
|--------|--------|-----|-----|
| Scaling | Automatic, per-request | Task/service based | Instance-based |
| Max duration | 15 min | Unlimited | Unlimited |
| Cold starts | Yes | No | No |
| Best for | Event-driven, short tasks | Long-running, containers | Full control, legacy |

Choose Lambda for event-driven, short-lived workloads. ECS for long-running services. EC2 when you need full OS control.

## Lambda Layers

Layers let you share common code and dependencies across multiple functions. Useful for large libraries (NumPy, Pandas, shared utilities).

```bash
# Create a layer
zip -r layer.zip python/
aws lambda publish-layer-version \
  --layer-name my-dependencies \
  --zip-file fileb://layer.zip \
  --compatible-runtimes python3.11

# Attach to a function
aws lambda update-function-configuration \
  --function-name my-function \
  --layers arn:aws:lambda:us-east-1:123456789012:layer:my-dependencies:1
```

Max layer size: 50 MB (zipped), 250 MB (unzipped) across all layers.

## API Gateway Integration

The most common Lambda pattern — expose Lambda as an HTTP API.

```
Client -> API Gateway -> Lambda -> DynamoDB
Client <- API Gateway <- Lambda <- DynamoDB
```

```bash
# Create a REST API with Lambda proxy integration
aws apigateway create-rest-api --name my-api

# Create resource
aws apigateway create-resource \
  --rest-api-id abc123 \
  --parent-id rootid \
  --path-part "items"

# Create POST method with Lambda integration
aws apigateway put-method \
  --rest-api-id abc123 --resource-id res123 \
  --http-method POST --authorization-type NONE

aws apigateway put-integration \
  --rest-api-id abc123 --resource-id res123 \
  --http-method POST \
  --type AWS_PROXY \
  --integration-http-method POST \
  --uri arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:123456789012:function:my-function/invocations

# Deploy
aws apigateway create-deployment --rest-api-id abc123 --stage-name prod
```

API Gateway handles request validation, throttling, API keys, and caching. Lambda handles the business logic.

---

## Interview Q&A

**Q1: How do you reduce cold start latency in Lambda?**
Several strategies: use Provisioned Concurrency to keep functions warm (eliminates cold starts entirely), use SnapStart for Java functions, reduce deployment package size (minimize dependencies, use Lambda Layers for shared code), choose faster-runtimes (Python/Node.js over Java/.NET), and avoid VPC attachment when possible. Also keep function initialization code outside the handler so it runs once per warm instance.

**Q2: When would you choose Lambda over ECS Fargate?**
Lambda is ideal for event-driven, short-lived tasks (under 15 minutes): file processing on S3 upload, API request handling, scheduled jobs, and stream processing. ECS Fargate is better for long-running services (web servers, background workers), workloads requiring consistent compute, microservices with sustained traffic, or tasks needing more than 10 GB memory. Lambda is also better when you want zero infrastructure management and pay-per-use billing for sporadic workloads.
