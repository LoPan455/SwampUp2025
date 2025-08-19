#!/bin/bash

# Source the check.sh script from lab1.1 to get access to the OIDC functions
source /root/swampup25/JFTD-110-GitHub_Actions_for_JFrog/scripts/jf_api_wrapper_utils.sh

echo "🔍 Lab 1.2 - Checking OIDC Identity Mapping"
echo "================================================"

# Configuration
SERVER_ID="academy"
PROVIDER_NAME="jfrog-githuboidc"
MAPPING_NAME="jfrog-repos"

echo "🔧 Configuration:"
echo "   Server ID: $SERVER_ID"
echo "   Provider Name: $PROVIDER_NAME"
echo "   Mapping Name: $MAPPING_NAME"
echo ""

# Check if the OIDC identity mapping exists
if jf_check_oidc_identity_mapping "$SERVER_ID" "$PROVIDER_NAME" "$MAPPING_NAME" true; then
    echo ""
    echo "✅ Lab 1.2 check passed - OIDC identity mapping exists"
    exit 0
else
    echo ""
    echo "❌ Lab 1.2 check failed - OIDC identity mapping does not exist"
    exit 1
fi
