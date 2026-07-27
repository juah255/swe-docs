# Google Cloud Platform (GCP) for DevOps

GCP is strong in data analytics, machine learning, and container-native
workloads. Its Kubernetes and networking support are best-in-class.

## Compute Engine

Scalable VMs with predefined/custom machine types, live migration, and
sustained-use discounts.

```bash
gcloud compute instances create my-vm \
  --zone=us-central1-a --machine-type=e2-medium \
  --image-family=ubuntu-2204-lts --image-project=ubuntu-os-cloud
gcloud compute instances list
gcloud compute ssh my-vm --zone=us-central1-a
gcloud compute instances delete my-vm --zone=us-central1-a
```
**AWS equivalent:** EC2

## Google Kubernetes Engine (GKE)

Managed Kubernetes with auto-scaling and optional Autopilot mode that
removes node management entirely.

```bash
gcloud container clusters create my-cluster \
  --zone=us-central1-a --num-nodes=3 --machine-type=e2-standard-2
gcloud container clusters get-credentials my-cluster --zone=us-central1-a
kubectl create deployment nginx --image=nginx --replicas=3
kubectl expose deployment nginx --port=80 --type=LoadBalancer
```
**AWS equivalent:** EKS

## Cloud Run

Fully managed serverless containers — deploy any container that listens
on a port with zero cluster or scaling config needed.

```bash
gcloud run deploy my-service \
  --image gcr.io/my-project/my-app:latest \
  --region us-central1 --allow-unauthenticated
gcloud run services update-traffic my-service \
  --to-revisions my-service-00003:20,my-service-00004:80
```
**AWS equivalent:** App Runner / Fargate (ECS)

## Cloud Storage

Object storage with Standard, Nearline (30-day min), Coldline (90-day
min), and Archive (365-day min) classes.

```bash
gsutil mb -l us-central1 gs://my-bucket-unique
gsutil cp ./data.csv gs://my-bucket/data.csv
gsutil cp gs://my-bucket/data.csv ./local-data.csv
```
**AWS equivalent:** S3

## Cloud SQL

Managed PostgreSQL, MySQL, and SQL Server with auto-patching and backups.

```bash
gcloud sql instances create my-db \
  --database-version=POSTGRES_15 --tier=db-f1-micro \
  --region=us-central1 --root-password=secret123
gcloud sql databases create app_db --instance=my-db
gcloud sql connect my-db --user=postgres
```
**AWS equivalent:** RDS

## VPC (Virtual Private Cloud)

GCP VPCs are global — subnets are regional. Firewall rules evaluated
globally.

```bash
gcloud compute networks create my-vnet --subnet-mode=custom
gcloud compute networks subnets create web-subnet \
  --network=my-vnet --region=us-central1 --range=10.0.1.0/24
gcloud compute firewall-rules create allow-ssh \
  --network=my-vnet --allow=tcp:22 \
  --source-ranges=0.0.0.0/0 --target-tags=ssh-allowed
```
**AWS equivalent:** VPC

## Identity and Access Management (IAM)

Policy-based roles at organization, folder, project, or resource level.
Roles are hierarchical and additive.

```bash
gcloud projects add-iam-policy-binding my-project \
  --member=user:devops@example.com --role=roles/compute.admin
gcloud iam service-accounts create my-app-sa \
  --display-name="My App Service Account"
```
**AWS equivalent:** IAM

## Cloud Monitoring

Metrics, uptime checks, dashboards, and alerting (formerly Stackdriver).

```bash
gcloud alpha monitoring policies create \
  --notification-channels=CHANNEL_ID \
  --condition-display-name="High CPU" \
  --condition-filter='resource.type="gce_instance"' \
  --condition-threshold-value=0.8 \
  --condition-threshold-duration=60s
```
**AWS equivalent:** CloudWatch

## Quick Comparison with AWS

| Concept | GCP | AWS |
|---|---|---|
| Compute | Compute Engine | EC2 |
| Containers | GKE / Cloud Run | EKS / Fargate |
| Object Storage | Cloud Storage | S3 |
| Managed SQL | Cloud SQL | RDS |
| Networking | VPC (global) | VPC (regional) |
| Identity | IAM | IAM |
| Monitoring | Cloud Monitoring | CloudWatch |

## Interview Q&As

### 1. How does GCP VPC differ from AWS VPC?

**Answer:** GCP VPCs are global — they span all regions without needing to
peer separate regional networks. Subnets are defined within regions, but
the VPC itself is a single global entity. In AWS, a VPC is scoped to a
single region, and you must use VPC peering or Transit Gateway to connect
across regions. GCP's model simplifies multi-region architectures.

### 2. When should you choose Cloud Run over GKE?

**Answer:** Choose Cloud Run for stateless HTTP workloads, event-driven
functions, and simple microservices where you want zero infrastructure
management. It auto-scales to zero and charges per request. Choose GKE
for long-running services, complex networking, stateful workloads, custom
operators, or when you need fine-grained Kubernetes control that Cloud
Run abstracts away.
