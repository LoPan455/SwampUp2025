# Source the jf_api_wrapper_utils.sh script to get access to the RT & Access OIDC functions
#source "$(dirname "$0")/../../jf_api_wrapper_utils.sh"
source /root/swampup25/JFTD-110-GitHub_Actions_for_JFrog/scripts/jf_api_wrapper_utils.sh

echo "🎯 Lab 1.1 - OIDC Provider Setup for GitHub Actions"
echo "================================================"

jf_check_all_oidc_providers academy jfrog-githuboidc


