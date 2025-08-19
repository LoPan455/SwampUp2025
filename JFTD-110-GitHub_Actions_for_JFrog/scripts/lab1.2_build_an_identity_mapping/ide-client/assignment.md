# Lab Instructions
Next we will configure an Identiy Mapping.  An identity mapping is the object that connects the Github Actions workflow run identity with a JFrog user, group or Admin.  You can have many identity mappings defined in one Integration object.
## JFrog Instance
1. Go into your OIDC Integration Page you created in the previous lab.
2. Under the "Identity Mappings" Section, ensure the "Global" tab is highlighted.
3. Click "Add Identity Mapping"
4. In the "Identity Mappings" fly-out, configure the following settings:
- **Name**: This can by any value, keep it simple
- **Priority**:  We are only creating one identity mapping, so you put any numerical value in here.  It's reommended to set as 100 to allow for adding other mappings easily before and after this one.
- **Description**: Feel free to add a description, but this is not required.
- **Claims JSON**:  This is where you will configure the *required* claims that *must* be present on the Identity Token that your Github Actions Workflow will send to your Jfrog Platform instance.  For details on what this identity token contains, refer to this [Github documentation page](https://docs.github.com/en/actions/concepts/security/about-security-hardening-with-openid-connect#understanding-the-oidc-token).  For now, we will keep things simple and add a JSON-formatted bit of text that will be similar to:
```
{ "repository": "<your Github username>/SwampUp2025"}
```
Replace `"jfrog/SwampUp2025"` with your actual repository name.
To do:  In "Access Token Settings" section , specify the "User name"  as "admin" ,  Service "artifactory" , Token Expiration time (In Minutes) =  use default 10 minutes. Click Save twice.
## Github Actions Workflow Specification
1. In your Github Actions Workflow Spec YAML file, add the `permissions` block as follows:
Note: This step is already done in the `.github/workflows/jftd-110-jfcli-node.yml`
```
name: "JFTD-110-GitHub_Actions_for_JFrog: NPM Package with OIDC"
description: "This workflow demonstrates how to use JFrog CLI with OIDC authentication to build and publish an NPM package, manage builds"
on:
  push:
    paths:
      - 'JFTD-110-GitHub_Actions_for_JFrog/**'
permissions:
  actions: read # for detecting the Github Actions environment.
  id-token: write # for creating OIDC tokens for signing.
  packages: write # for uploading attestations.
  contents: read
  security-events: write # Required for uploading code scanning.
```
This will allow your Github Actions workflow to request an identity token from the Github OIDC service.

2. Configure your Github Actions workflow to checkout your code and fetch an Access Token from your JPD:
```
jobs:

  npmPackage:
    name: "NPM Package"
    runs-on: ubuntu-latest  # node:22-alpine
    env:
      BUILD_NAME: "lab110-npm-oidc"
      BUILD_ID: "ga-npm-${{github.run_number}}"
    defaults:
       run:
         working-directory: ${{env.WORKSPACE_NPM}}
    steps:
      - name: "Checkout Repository"
        continue-on-error: true
        uses: actions/checkout@v4

      - name: "Get Artifactory Access Token and Setup JFrog CLI"
        uses: jfrog/setup-jfrog-cli@v4
        id: setup-cli
        env:
          JF_URL: ${{vars.JF_RT_URL}}   # example: http://academy-artifactory.dzmfffgzzkmf.instruqt.io
        with:
          version: latest
          oidc-provider-name: ${{ vars.JF_OIDC_PROVIDER_NAME }}
```
3. (Optional) We can configure a short step in the workflow to verify that we have a value set as output to the "Get Artifactory Access Token" step by adding the following:
Note: This step is already done in the `.github/workflows/jftd-110-jfcli-node.yml`
```
      - name: "Run only if value is present"
        if: steps.setup-jfrog-cli.outputs.oidc-token != ''
        run: |
          echo "Access Token set as output to 'Get Artifactory Access Token and Setup JFrog CLI'"
```
