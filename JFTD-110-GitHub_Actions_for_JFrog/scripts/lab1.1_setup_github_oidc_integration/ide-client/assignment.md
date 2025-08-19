In this lab, you will configure your JFrog Platform instance to return an ephemeral JFrog Access Token to a Github Actions workflow run.
We will first setup the OIDC integration and create an [Identity Mapping](https://jfrog.com/help/r/jfrog-platform-administration-documentation/understanding-the-oidc-token).  This will allow each student's Github Actions workflow run to authenticate to each JPD.
### Step 1: Create the Github OIDC Integration object in your JFrog Platform instance
1. Log into your JFrog Platform interface (JFrog Platform UI tab).

[button label="JFrog Platform UI"](tab-0)

```
			- User: admin
			- Password: Admin1234!
```
2. Navigate to `Administration -> General Management -> Manage Integrations - > New Integration -> OpenID Connect tab -> New Integration`.
3. Select `Open ID Connect` in the drop-down menu.
4. Enter the following values in the fields:
* **Provider Name:** Can be anything, but Name cannot contain spaces or special characters.  Hyphens (`-`) are acceptable.
For this lab please  call it
```
jfrog-githuboidc
```
* **Provider Type:** `Github`
* **Description:** Not required, can skip
* **Provider URL**: Autofilled after selecting “Provider Type”
* **Audience:** Leave Blank
* **Organization:** The student’s Github account name, usually the same as the student’s Github user name. ( To discuss: there is no "Organization" field in this screen)
5. Click **Save**
6. Next click on `jfrog-githuboidc` to open it in edit mode.
7. Click “Show Snippet” to reveal a small snippet of YAML .  This is a minmal configuration that would be required to properly configure your workflow to use the oidc integration we just created.  As a convenience,  the below configuration block  covers the necessary configuration.
**Note:** When you paste this section in the `TODO: Lab 1.1` section in the `.github/workflows/jftd-110-jfcli-node.yml` you  have to remove a tab-space in the first line so that the resulling YAML is well-formed.
```
      - name: "Get Artifactory Access Token and Setup JFrog CLI"
        uses: jfrog/setup-jfrog-cli@v4
        id: setup-cli
        env:
          JF_URL: ${{vars.JF_RT_URL}}   # example: http://academy-artifactory.dzmfffgzzkmf.instruqt.io
        with:
          version: latest
          oidc-provider-name: jfrog-githuboidc
```
**Optional:**  The OIDC provider name  `jfrog-githuboidc` can be configured as a Github Action  Repository Variable named `JF_OIDC_PROVIDER_NAME` and reference it as mentioned in the  `TODO: Lab 1.1` section in the `.github/workflows/jftd-110-jfcli-node.yml` .









