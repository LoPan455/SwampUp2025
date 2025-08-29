#!/bin/bash

exec 2>&1
exec > /tmp/lab-setup.out

source /root/.bashrc

log_error () {
    echo -e "[`date`]\033[31mERROR: $1\033[0m"
}

log_task () {
    echo -e "[`date`]\033[32mTASK: $1\033[0m"
}

log_task "Started Lab setup"

# cd swampup25/JFTD-110-GitHub_Actions_for_JFrog

snap install jq
log_task "Installed jq"

# Wait for Artifactory
while [ true ]
do
    wget http://academy-artifactory  > /dev/null 2>&1
    if [ $? -eq 0 ]
    then   
        break
    fi
done
log_task "Artifactory is responding"



log_task "JF Config executed"

jf rt curl \
    -X PATCH \
    -H "Content-Type: application/yaml" \
    -T /root/swampup25/JFTD-110-GitHub_Actions_for_JFrog/scripts/setup/lab110-repo-npm-def-all.yaml \
     "api/system/configuration" --server-id=academy

log_task "Repositories created"

jf xr curl -XPOST "ui/unified/binMgr/v1/setIndexedBuilds" \
-H "content-type:application/json" --server-id=academy \
-d '{
  "new_state": {
    "config_type": 1,
    "exclude_patterns": [],
    "include_patterns": [
      {
        "pattern": "*/**"
      }
    ]
  },
  "previous_state": {
    "is_vuln_contextual_supported": true,
    "has_vuln_contextual_analysis_config_lock": false,
    "show_promote_tip_for_vuln_contextual_analysis": false,
    "config_type": 0
  }
}'
log_task "Indexed All builds by Pattern"

log_task "START - Creating Curation Policy for malicious"
jf xr curl -XPOST "api/v1/curation/policies" \
-H "content-type:application/json" --server-id=academy \
-d ' {
  "name": "maliciouspackage",
  "condition_id": "1",
  "scope": "all_repos",
  "policy_action": "block",
  "waiver_request_config": "forbidden"
}'
log_task "END - Creating Curation Policy for malicious"

log_task "START - Creating Curation Policy for CVE with CVSS score between 7.0 and 8.9 (with or without a fix version available)"

jf xr curl -XPOST "api/v1/curation/policies" \
-H "content-type:application/json" --server-id=academy \
-d ' {
  "name": "CVEwithCVSS7-9",
  "condition_id": "5",
  "scope": "all_repos",
  "policy_action": "block",
  "waiver_request_config": "auto_approved"
}'

log_task "END - Creating Curation Policy for CVE with CVSS score between 7.0 and 8.9 (with or without a fix version available)"

# chmod +x JFTD-110-GitHub_Actions_for_JFrog/labs1_setup/update_repo_environments.sh

# curl -X POST \
#   -H "Content-Type: application/json" \
#   -H "Authorization: Bearer  $JFROG_ACCESS_TOKEN" \
#   -d '{"name": "QA"}' \
#   "http://academy-artifactory/access/api/v1/environments"

# log_task "Environment QA created"

# log_task "Updating repository environments"

# bash JFTD-110-GitHub_Actions_for_JFrog/labs1_setup/update_repo_environments.sh academy lab110-npm-dev-local DEV
# bash JFTD-110-GitHub_Actions_for_JFrog/labs1_setup/update_repo_environments.sh academy lab110-npm-prod-local PROD
# bash JFTD-110-GitHub_Actions_for_JFrog/labs1_setup/update_repo_environments.sh academy lab110-npm-qa-local QA

# log_task "Repositories Assigned to environments"

# DEFAULT_SIGNING_KEY="default-signing-key"

# read -p "Enter RBV2 Signing key [${DEFAULT_SIGNING_KEY}]: " RBV2_SIGNING_KEY

# # Use default if input is empty
# RBV2_SIGNING_KEY="${RBV2_SIGNING_KEY:-$DEFAULT_SIGNING_KEY}"

# export RBV2_SIGNING_KEY

# JFTD-110-GitHub_Actions_for_JFrog/labs2_RBv2/auto_generate_upload_gpg_key.sh "$RBV2_SIGNING_KEY"
# log_task "GPG Key generated and uploaded to Artifactory for RBv2 signing"
