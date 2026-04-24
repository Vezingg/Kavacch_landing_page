#!/bin/bash
# Quick Start Deployment Script for kavacch-agent-lite-494311

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PROJECT_ID="kavacch-agent-lite-494311"
SERVICE_NAME="kalash-landing-page"
REGION="us-central1"

echo -e "${YELLOW}=== Cloud Run Deployment Script ===${NC}"
echo -e "Project: ${GREEN}$PROJECT_ID${NC}"
echo -e "Service: ${GREEN}$SERVICE_NAME${NC}"
echo -e "Region: ${GREEN}$REGION${NC}"
echo ""

# Step 1: Check if gcloud is installed
echo -e "${YELLOW}[1/6] Checking gcloud installation...${NC}"
if ! command -v gcloud &> /dev/null; then
    echo -e "${RED}✗ gcloud CLI not found. Please install it first.${NC}"
    echo "Visit: https://cloud.google.com/sdk/docs/install"
    exit 1
fi
echo -e "${GREEN}✓ gcloud CLI found${NC}"

# Step 2: Set project
echo -e "${YELLOW}[2/6] Setting GCP project...${NC}"
gcloud config set project $PROJECT_ID
echo -e "${GREEN}✓ Project set to $PROJECT_ID${NC}"

# Step 3: Enable APIs
echo -e "${YELLOW}[3/6] Enabling required APIs...${NC}"
gcloud services enable run.googleapis.com --quiet
gcloud services enable cloudbuild.googleapis.com --quiet
echo -e "${GREEN}✓ APIs enabled${NC}"

# Step 4: Build and Deploy
echo -e "${YELLOW}[4/6] Building and deploying Docker image...${NC}"
gcloud run deploy $SERVICE_NAME \
  --project $PROJECT_ID \
  --region $REGION \
  --source . \
  --allow-unauthenticated \
  --quiet

echo -e "${GREEN}✓ Deployment successful${NC}"

# Step 5: Get service URL
echo -e "${YELLOW}[5/6] Retrieving service URL...${NC}"
SERVICE_URL=$(gcloud run services describe $SERVICE_NAME \
  --project $PROJECT_ID \
  --region $REGION \
  --format='value(status.url)')

echo -e "${GREEN}✓ Service URL: $SERVICE_URL${NC}"

# Step 6: Test the service
echo -e "${YELLOW}[6/6] Testing the service...${NC}"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" $SERVICE_URL)
if [ "$HTTP_CODE" -eq 200 ] || [ "$HTTP_CODE" -eq 304 ]; then
    echo -e "${GREEN}✓ Service is running! (HTTP $HTTP_CODE)${NC}"
else
    echo -e "${YELLOW}⚠ Service returned HTTP $HTTP_CODE${NC}"
fi

echo ""
echo -e "${GREEN}=== Deployment Complete ===${NC}"
echo ""
echo "Service URL: $SERVICE_URL"
echo ""
echo "Quick commands:"
echo "  View logs:     gcloud run logs read $SERVICE_NAME --project $PROJECT_ID --region $REGION --limit=50 --follow"
echo "  Redeploy:      gcloud run deploy $SERVICE_NAME --project $PROJECT_ID --region $REGION --source . --allow-unauthenticated --quiet"
echo "  Delete:        gcloud run services delete $SERVICE_NAME --project $PROJECT_ID --region $REGION"
