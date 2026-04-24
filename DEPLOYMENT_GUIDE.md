# Complete GCP Cloud Run Deployment Guide
## For: kavacch-agent-lite-494311 | kalash-landing-page

---

## STEP 1: Initial GCP Setup & Authentication

### 1.1 Install Google Cloud CLI (if not already installed)
```bash
# macOS
brew install google-cloud-sdk

# Linux (Ubuntu/Debian)
curl https://sdk.cloud.google.com | bash
exec -l $SHELL

# Windows
# Download from: https://cloud.google.com/sdk/docs/install-sdk#windows
```

### 1.2 Initialize gcloud & Authenticate
```bash
# Initialize gcloud
gcloud init

# Login to your Google account
gcloud auth login

# Set the default project
gcloud config set project kavacch-agent-lite-494311

# Verify the active project
gcloud config list
```

### 1.3 Authenticate Docker with GCP (if pushing to Artifact Registry)
```bash
# Configure Docker authentication
gcloud auth configure-docker us-central1-docker.pkg.dev

# Verify authentication
docker info
```

---

## STEP 2: Create GCP Project Resources

### 2.1 Set Environment Variables (for easy copy-paste)
```bash
PROJECT_ID="kavacch-agent-lite-494311"
SERVICE_NAME="kalash-landing-page"
REGION="us-central1"
IMAGE_NAME="kalash-landing-page"
REGISTRY_REGION="us-central1"
```

### 2.2 Enable Required APIs
```bash
gcloud services enable run.googleapis.com \
  --project=$PROJECT_ID

gcloud services enable artifactregistry.googleapis.com \
  --project=$PROJECT_ID

gcloud services enable cloudbuild.googleapis.com \
  --project=$PROJECT_ID
```

### 2.3 Create Artifact Registry Repository (optional but recommended)
```bash
gcloud artifacts repositories create kalash-registry \
  --repository-format=docker \
  --location=$REGISTRY_REGION \
  --project=$PROJECT_ID
```

---

## STEP 3: Build & Deploy Docker Image

### Option A: Direct Deployment (Recommended - No Registry Needed)
```bash
# Build and deploy directly from source
gcloud run deploy kalash-landing-page \
  --project kavacch-agent-lite-494311 \
  --region us-central1 \
  --source . \
  --allow-unauthenticated \
  --quiet

# Verify deployment success
echo "Waiting for service to be ready..."
sleep 5

# Get the service URL
SERVICE_URL=$(gcloud run services describe kalash-landing-page \
  --project kavacch-agent-lite-494311 \
  --region us-central1 \
  --format='value(status.url)')

echo "Service URL: $SERVICE_URL"

# Test the deployment
curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" $SERVICE_URL
```

### Option B: Build with Artifact Registry (For Production/CI-CD)
```bash
# Set image URL
IMAGE_URL="${REGISTRY_REGION}-docker.pkg.dev/${PROJECT_ID}/kalash-registry/${IMAGE_NAME}:latest"

# Build the image
gcloud builds submit \
  --tag $IMAGE_URL \
  --project=$PROJECT_ID

# Deploy from the image
gcloud run deploy kalash-landing-page \
  --image $IMAGE_URL \
  --project $PROJECT_ID \
  --region $REGION \
  --allow-unauthenticated \
  --quiet
```

### Option C: Local Docker Build & Push
```bash
# Build locally
docker build -t kalash-landing-page:latest .

# Tag for Artifact Registry
docker tag kalash-landing-page:latest \
  ${REGISTRY_REGION}-docker.pkg.dev/${PROJECT_ID}/kalash-registry/kalash-landing-page:latest

# Push to registry
docker push ${REGISTRY_REGION}-docker.pkg.dev/${PROJECT_ID}/kalash-registry/kalash-landing-page:latest

# Deploy
gcloud run deploy kalash-landing-page \
  --image ${REGISTRY_REGION}-docker.pkg.dev/${PROJECT_ID}/kalash-registry/kalash-landing-page:latest \
  --project $PROJECT_ID \
  --region $REGION \
  --allow-unauthenticated \
  --quiet
```

---

## STEP 4: Verify Deployment

### 4.1 Get Service Details
```bash
# Get the service URL
gcloud run services describe kalash-landing-page \
  --project kavacch-agent-lite-494311 \
  --region us-central1 \
  --format='value(status.url)'

# Get full service details
gcloud run services describe kalash-landing-page \
  --project kavacch-agent-lite-494311 \
  --region us-central1
```

### 4.2 Test the Service
```bash
# Get URL and test
SERVICE_URL=$(gcloud run services describe kalash-landing-page \
  --project kavacch-agent-lite-494311 \
  --region us-central1 \
  --format='value(status.url)')

echo "Testing: $SERVICE_URL"
curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" $SERVICE_URL

# Or with verbose output
curl -v $SERVICE_URL
```

### 4.3 View Logs
```bash
# Real-time logs
gcloud run logs read kalash-landing-page \
  --project kavacch-agent-lite-494311 \
  --region us-central1 \
  --limit=50 \
  --follow

# Or use Cloud Logging
gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=kalash-landing-page" \
  --project kavacch-agent-lite-494311 \
  --limit=50
```

---

## STEP 5: One-Liner Deployment Command (Like Your Previous One)

```bash
gcloud run deploy kalash-landing-page \
  --project kavacch-agent-lite-494311 \
  --region us-central1 \
  --source . \
  --allow-unauthenticated \
  --quiet && \
echo "✓ Deployment complete! Service URL:" && \
gcloud run services describe kalash-landing-page \
  --project kavacch-agent-lite-494311 \
  --region us-central1 \
  --format='value(status.url)'
```

---

## STEP 6: Update Service Settings (if needed)

### 6.1 Update Environment Variables
```bash
gcloud run services update kalash-landing-page \
  --update-env-vars KEY=VALUE \
  --project kavacch-agent-lite-494311 \
  --region us-central1
```

### 6.2 Update Memory/CPU
```bash
gcloud run services update kalash-landing-page \
  --memory 512Mi \
  --cpu 1 \
  --project kavacch-agent-lite-494311 \
  --region us-central1
```

### 6.3 Update Timeout
```bash
gcloud run services update kalash-landing-page \
  --timeout 300 \
  --project kavacch-agent-lite-494311 \
  --region us-central1
```

---

## STEP 7: Cleanup & Deletion

### 7.1 Delete Service
```bash
gcloud run services delete kalash-landing-page \
  --project kavacch-agent-lite-494311 \
  --region us-central1
```

### 7.2 Delete Artifact Registry (if created)
```bash
gcloud artifacts repositories delete kalash-registry \
  --location $REGISTRY_REGION \
  --project=$PROJECT_ID
```

---

## STEP 8: Troubleshooting

### Check gcloud configuration
```bash
gcloud config list
gcloud auth list
```

### Verify APIs are enabled
```bash
gcloud services list --enabled --project kavacch-agent-lite-494311
```

### Check service status
```bash
gcloud run services list --project kavacch-agent-lite-494311
```

### View build logs (if build fails)
```bash
gcloud builds log --stream --project kavacch-agent-lite-494311
```

---

## Cheat Sheet - Quick Commands

```bash
# Quick deployment (after initial setup)
gcloud run deploy kalash-landing-page --project kavacch-agent-lite-494311 --region us-central1 --source . --allow-unauthenticated --quiet

# Get URL
gcloud run services describe kalash-landing-page --project kavacch-agent-lite-494311 --region us-central1 --format='value(status.url)'

# Test
curl $(gcloud run services describe kalash-landing-page --project kavacch-agent-lite-494311 --region us-central1 --format='value(status.url)')

# View logs
gcloud run logs read kalash-landing-page --project kavacch-agent-lite-494311 --region us-central1 --limit=50 --follow
```

---

## Important Notes

1. **Project ID**: `kavacch-agent-lite-494311`
2. **Service Name**: `kalash-landing-page`
3. **Region**: `us-central1` (can change to other regions if needed)
4. **Allow Unauthenticated**: Your service is publicly accessible
5. **Billing**: Cloud Run charges per request and compute time - monitor your usage
6. **First-time setup**: This process may take 5-10 minutes for APIs to enable

---

## Environment Variables Reference

Save this in `.env` for easy access:
```bash
PROJECT_ID="kavacch-agent-lite-494311"
SERVICE_NAME="kalash-landing-page"
REGION="us-central1"
IMAGE_NAME="kalash-landing-page"
REGISTRY_REGION="us-central1"
REGISTRY_NAME="kalash-registry"
```

Then use:
```bash
source .env
gcloud run deploy $SERVICE_NAME --project $PROJECT_ID --region $REGION --source . --allow-unauthenticated --quiet
```
