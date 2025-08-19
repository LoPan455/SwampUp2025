#!/bin/bash
# Source the jf_api_wrapper_utils.sh script to get access to the RT & Access OIDC functions

source /root/swampup25/JFTD-110-GitHub_Actions_for_JFrog/scripts/jf_api_wrapper_utils.sh

echo "🎯 Lab 0 - Configure NPM Virtual Repository for GitHub Actions"
echo "============================================================="

# === Script Entry Point ===
jf_check_all_repos academy lab110-npm-sandbox-local lab110-npm-remote lab110-npm-virtual