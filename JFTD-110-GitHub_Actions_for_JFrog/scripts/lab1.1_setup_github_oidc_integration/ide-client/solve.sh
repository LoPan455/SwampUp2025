#!/bin/bash

# Source the jf_api_wrapper_utils.sh script to get access to the RT & Access OIDC functions
#source "$(dirname "$0")/../../jf_api_wrapper_utils.sh"
source /root/swampup25/JFTD-110-GitHub_Actions_for_JFrog/scripts/jf_api_wrapper_utils.sh

jf_solve_lab_1_1() {
    # Solve Lab 1.1 by creating the required OIDC provider
    # Usage: jf_solve_lab_1_1 <server_id> [provider_name] [debug]
    # Returns: 0 if successful, 1 if provider already exists, 2 on error
    
    local server_id="$1"
    local provider_name="${2:-jfrog-githuboidc}"
    local debug="${3:-false}"
    
    if [ -z "$server_id" ]; then
        echo "Usage: jf_solve_lab_1_1 <server_id> [provider_name] [debug]" >&2
        return 2
    fi
    
    echo "🎯 Solving Lab 1.1 - Creating OIDC Provider for GitHub Actions"
    echo "================================================"
    
    # Test connectivity first
    echo "1. Testing server connectivity..."
    if ! jf_test_connectivity "$server_id" >/dev/null 2>&1; then
        echo "❌ Cannot connect to server '$server_id'"
        return 2
    fi
    echo "✅ Server connectivity confirmed"
    echo ""
    
    # Create the OIDC provider
    echo "2. Creating OIDC provider '$provider_name'..."
    if jf_create_oidc_provider "$server_id" "$provider_name" \
        "https://token.actions.githubusercontent.com" \
        "GitHub" \
        "This is a test configuration created for OIDC-Access integration test" \
        "" \
        "$debug"; then
        echo ""
        echo "3. Verifying provider creation..."
        if jf_oidc_provider_check "$server_id" "$provider_name"; then
            echo ""
            echo "🎉 Lab 1.1 completed successfully!"
            echo "✅ OIDC provider '$provider_name' is ready for GitHub Actions integration"
            return 0
        else
            echo "❌ Provider verification failed"
            return 2
        fi
    else
        local exit_code=$?
        if [ $exit_code -eq 1 ]; then
            echo ""
            echo "3. Verifying existing provider..."
            if jf_oidc_provider_check "$server_id" "$provider_name"; then
                echo ""
                echo "🎉 Lab 1.1 already completed!"
                echo "✅ OIDC provider '$provider_name' already exists and is ready"
                return 0
            else
                echo "❌ Provider verification failed"
                return 2
            fi
        else
            echo "❌ Failed to create OIDC provider"
            return 2
        fi
    fi
}

echo "🎯 Lab 1.1 - OIDC Provider Setup for GitHub Actions"
echo "================================================"


# Set the server ID and JF_URL
SERVER_ID="academy1"
# JF_URL="http://$_SANDBOX_ID.instruqt.io"

echo "🔧 Configuration:"
echo "   Server ID: $SERVER_ID"
# echo "   JFrog URL: $JF_URL"
echo ""

# Solve Lab 1.1 by creating the OIDC provider
if jf_solve_lab_1_1 "$SERVER_ID" "jfrog-githuboidc" true; then
    echo ""
    echo "🎉 Lab 1.1 completed successfully!"
    echo "✅ OIDC provider 'jfrog-githuboidc' is ready for GitHub Actions integration"
    echo ""
    echo "📋 Next steps:"
    echo "   1. Use this OIDC provider in your GitHub Actions workflow"
    echo "   2. Configure the workflow to use OIDC authentication"
    echo "   3. Test the integration"
    echo ""
    echo "🔗 Reference: https://jfrog.com/help/r/jfrog-platform-administration-documentation/sample-integration-of-jfrog-oidc-with-github-actions"
else
    echo ""
    echo "❌ Lab 1.1 failed. Please check the error messages above."
    exit 1
fi

