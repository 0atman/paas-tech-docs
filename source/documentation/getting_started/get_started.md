# Get started

## Get an account

Your department, agency or team must have a GOV.UK PaaS account. This account is called an organisation, or [org](orgs_spaces_users.html#organisations). Sign up for an org account at [https://www.cloud.service.gov.uk/signup](https://www.cloud.service.gov.uk/signup).

Once your department, agency or team has an org account, you will need a personal account. Ask your [org manager](orgs_spaces_users.html#org-manager) to authorise the creation of your personal account.

The GOV.UK PaaS is hosted in 2 independent regions, London and Ireland. 

By default, the GOV.UK PaaS team creates new accounts in the London region unless you request otherwise during sign up. 

To provide you with an account, we need to store some personal data about you. Please see our [privacy notice](https://www.cloud.service.gov.uk/privacy-notice) for details.

Once you have a personal account, you can access the GOV.UK PaaS admin tool for either the [London](https://admin.london.cloud.service.gov.uk/) or the [Ireland](https://admin.cloud.service.gov.uk/) region (requires sign in). This tool allows you to view and manage your [orgs](orgs_spaces_users.html#organisations), [spaces](orgs_spaces_users.html#spaces) and [users](orgs_spaces_users.html#users-and-user-roles) without using the command line. Your level of access depends on your user role permissions.

Contact us by emailing [gov-uk-paas-support@digital.cabinet-office.gov.uk](mailto:gov-uk-paas-support@digital.cabinet-office.gov.uk) if you have any questions.

## Set up the Cloud Foundry command line

GOV.UK PaaS is hosted on [Cloud Foundry](https://www.cloudfoundry.org/) [external link]. You must use the Cloud Foundry command line interface (CLI) to manage your apps hosted on the GOV.UK PaaS. To set it up:

1. Download and install the [Cloud Foundry CLI](https://github.com/cloudfoundry/cli#downloads) [external link] for your platform.

2. To check that it is installed correctly, run `cf -v` in the command line.

    If it has installed correctly, you will receive the `cf version X.X.X…` confirmation message.

    Depending on your network configuration, you might need to set an [`HTTP_PROXY` environment variable](https://docs.cloudfoundry.org/cf-cli/http-proxy.html) [external link] for the CLI to connect. Contact your network administrator for your configuration settings.

3. Sign in to Cloud Foundry. If your org is hosted in the London region, run:

    ```
    cf login -a api.london.cloud.service.gov.uk -u USERNAME
    ```

    If your org is hosted in the Ireland region, run:

    ```
    cf login -a api.cloud.service.gov.uk -u USERNAME
    ```

    `USERNAME` is your personal account email address.

4. Enter the password you set during the sign up process.

When you are signed in, run `cf` in the command line to see all available commands.

## Deploy a test static HTML page

You can practice deploying an app by deploying a test static HTML page.

1. To deploy an app, you must select a [target](deploying_apps.html#set-a-target). This is a combination of an [organisation](orgs_spaces_users.html#organisations) and a [space](orgs_spaces_users.html#spaces).

    All orgs have a sandbox space for you to use when learning about the PaaS. When deploying a test static HTML page, you should target this sandbox space by running:

    ```
    cf target -o ORGNAME -s sandbox
    ```

    where `ORGNAME` is your org and `sandbox` is the name of the sandbox space.

    If you deploy an app using the same name and target as an existing app, the original will be replaced. If you are not sure about where to deploy your app, consult the rest of your team or speak to the PaaS team by emailing [gov-uk-paas-support@digital.cabinet-office.gov.uk](mailto:gov-uk-paas-support@digital.cabinet-office.gov.uk).

2. In an empty directory, create an `index.html` file containing the following markup:.

    ```
    <html>
      <head>
        <title>Static Site</title>
      </head>
      <body>
        <p>Welcome to the static site!</p>
      </body>
    </html>
    ```

3. Create a `manifest.yml` file in the same directory as the `index.html` file. The manifest file tells Cloud Foundry what to do with your app.

    ```
    ---
    applications:
    - name: APPNAME
      memory: 64M
      buildpack: staticfile_buildpack
    ```

    where `APPNAME` is the unique name for your app. You can run `cf apps` to see apps which already exist.

    The `memory` line tells the PaaS how much memory to allocate to the app.

    A buildpack provides app framework and runtime support. For example, if your app was written in Ruby, you would use the `ruby_buildpack`. In this example, we use the `staticfile_buildpack` for the static HTML page.

4. In the directory where you created the files, run `cf push APPNAME` to push the static HTML page to the GOV.UK PaaS.

    If you do not specify the app name in `cf push`, the name specified in the manifest file is used.

    The static HTML page is now available at `https://APPNAME.cloudapps.digital`.

For a production app, you should read the [production checklist](deploying_apps.html#production-checklist).
