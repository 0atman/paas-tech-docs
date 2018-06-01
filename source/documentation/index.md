# Technical documentation for GOV.UK PaaS

GOV.UK Platform as a Service (PaaS) is a cloud-hosting platform being built by the Government Digital Service (GDS). GOV.UK PaaS manages the deployment of your apps, services and background tasks so you don’t need to hire people with specialist cloud skills.

GOV.UK PaaS is currently in private beta.

GOV.UK PaaS is built using the open source [Cloud Foundry](https://www.cloudfoundry.org/) project, and runs on Amazon Web Services. [Read our blog post](https://governmentasaplatform.blog.gov.uk/2015/12/17/choosing-cloudfoundry/) for more information on why we chose Cloud Foundry. Refer to the [features page](https://www.cloud.service.gov.uk/features) for more information on the GOV.UK PaaS.

If you want to use the platform to host your app, contact us by emailing [gov-uk-paas-support@digital.cabinet-office.gov.uk](mailto:gov-uk-paas-support@digital.cabinet-office.gov.uk).

# Before you start

To start using the platform, your department, agency or team must agree to the Terms of Use.

To be hosted on the GOV.UK PaaS, your app must:

- follow the [twelve-factor application principles](/#12-factor-application-principles); this will be true if your app was written to be deployed to another PaaS like Heroku
- [store data classified up to ‘official’](/#data-security-classification); your app cannot store data classified as 'secret' or 'top secret'
- be built using a supported [buildpack](/#buildpacks) or written in one of these languages:
    - Go
    - Nodejs
    - Java
    - PHP
    - Python
    - Ruby
    - static HTML/CSS/Javascript site

[Cloud Foundry buildpacks](/#buildpacks) provide runtime and framework support for your application. For most languages, you will need to provide configuration files to describe your app’s dependencies. Most buildpacks will support a limited range of versions of the language.

# Get started

## Get an account

GOV.UK PaaS is currently in private beta.

Your department, agency or team must have a GOV.UK PaaS account. This account is called an organisation, or [org](/#organisations). Sign up for an org account at [https://www.cloud.service.gov.uk/signup](https://www.cloud.service.gov.uk/signup).

If your department, agency or team already has an org account and you need an individual account, talk to your [org manager](/#org-manager) who will need to authorise the creation of your account.

In order to provide you with an account, we need to store some personal data about you. Please see our [Privacy Policy](/#privacy-policy) for details.

Contact us by emailing [gov-uk-paas-support@digital.cabinet-office.gov.uk](mailto:gov-uk-paas-support@digital.cabinet-office.gov.uk) if you have any questions.

## Set up command line

GOV.UK PaaS is hosted on [Cloud Foundry](https://www.cloudfoundry.org/) [external link]. You must use the Cloud Foundry command line interface (CLI) to manage your apps hosted on the GOV.UK PaaS. To set it up:

1. Download and install the [Cloud Foundry CLI](https://github.com/cloudfoundry/cli#downloads) [external link] for your platform.

    Installing with Homebrew does not work on macOS Sierra. We recommend using the Mac binary or installer.

2. To check that it is installed correctly, run `cf -v` in the command line.

    If it has installed correctly, you will receive the `cf version X.X.X…` confirmation message.

    Depending on your network configuration, you might need to set an [`HTTP_PROXY` environment variable](https://docs.cloudfoundry.org/cf-cli/http-proxy.html) [external link] for the CLI to connect. Contact your network administrator for your configuration settings.

3. Sign in to Cloud Foundry by running:

    ```
    cf login -a api.cloud.service.gov.uk -u USERNAME
    ```

    where `USERNAME` is your individual account email address.

4. Enter your password (you set this password when you clicked on the invite link in your welcome email).

Once you are logged in, run `cf` in the command line to see all available commands.

## Deploy a test static HTML page

You can practice deploying an app by deploying a test static HTML page.

1. To deploy an app, you must select a [target](/#set-a-target). This is a combination of an [organisation](/#organisations) and a [space](/#spaces).

    All orgs have a sandbox space for you to use when learning about the PaaS. When deploying a test static HTML page, you should target this sandbox space by running:

    ```
    cf target -o ORGNAME -s sandbox
    ```

    where `ORGNAME` is your org and `sandbox` is the name of the sandbox space.

    If you deploy an app using the same name and target as an existing app, the original will be replaced. If you are not sure about where to deploy your app, consult the rest of your team or speak to the PaaS team by emailing [gov-uk-paas-support@digital.cabinet-office.gov.uk](mailto:gov-uk-paas-support@digital.cabinet-office.gov.uk)..

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

For a production app, you should read the [production checklist](/#production-checklist).
