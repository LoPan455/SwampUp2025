#!/bin/bash

# Source the check.sh script from lab1.1 to get access to the OIDC functions
source /root/swampup25/JFTD-110-GitHub_Actions_for_JFrog/scripts/jf_api_wrapper_utils.sh

echo "🎯 Lab 1.2 - Creating OIDC Identity Mapping"
echo "================================================"

# Configuration
SERVER_ID="academy1"
PROVIDER_NAME="jfrog-githuboidc"
MAPPING_NAME="jfrog-repos"
GIT_ORG="jfrog"
GIT_REPO="SwampUp2025"

echo "🔧 Configuration:"
echo "   Server ID: $SERVER_ID"
echo "   Provider Name: $PROVIDER_NAME"
echo "   Mapping Name: $MAPPING_NAME"
echo "   Git Organization: $GIT_ORG"
echo "   Git Repository: $GIT_REPO"
echo ""

# First, verify the OIDC provider exists
echo "1. Verifying OIDC provider exists..."
if ! jf_oidc_provider_check "$SERVER_ID" "$PROVIDER_NAME" >/dev/null 2>&1; then
    echo "❌ OIDC provider '$PROVIDER_NAME' does not exist. Please run Lab 1.1 first."
    exit 1
fi
echo "✅ OIDC provider '$PROVIDER_NAME' exists"
echo ""

# Create the OIDC identity mapping
echo "2. Creating OIDC identity mapping..."
if jf_create_oidc_identity_mapping "$SERVER_ID" "$PROVIDER_NAME" "$MAPPING_NAME" "$GIT_ORG" "$GIT_REPO" true; then
    echo ""
    echo "3. Verifying identity mapping creation..."
    if jf_check_oidc_identity_mapping "$SERVER_ID" "$PROVIDER_NAME" "$MAPPING_NAME"; then
        echo ""
        echo "🎉 Lab 1.2 completed successfully!"
        echo "✅ OIDC identity mapping '$MAPPING_NAME' is ready for GitHub Actions integration"
        echo ""
        echo "📋 Mapping Details:"
        echo "   - Name: $MAPPING_NAME"
        echo "   - Description: $GIT_ORG/**"
        echo "   - Repository: $GIT_ORG/$GIT_REPO"
        echo "   - Username: admin"
        echo "   - Scope: applied-permissions/admin"
        echo "   - Audience: *@*"
        echo "   - Expires In: 600 seconds"
        echo "   - Priority: 1"
        exit 0
    else
        echo "❌ Identity mapping verification failed"
        exit 1
    fi
else
    exit_code=$?
    if [ $exit_code -eq 1 ]; then
        echo ""
        echo "3. Verifying existing identity mapping..."
        if jf_check_oidc_identity_mapping "$SERVER_ID" "$PROVIDER_NAME" "$MAPPING_NAME"; then
            echo ""
            echo "🎉 Lab 1.2 already completed!"
            echo "✅ OIDC identity mapping '$MAPPING_NAME' already exists and is ready"
            exit 0
        else
            echo "❌ Identity mapping verification failed"
            exit 1
        fi
    else
        echo "❌ Failed to create OIDC identity mapping"
        exit 1
    fi
fi