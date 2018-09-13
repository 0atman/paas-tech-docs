# Monitoring apps

## Metrics

Cloud Foundry provides time-series data, or metrics, for each instance of your PaaS app. You can use either [Prometheus](https://prometheus.io/) [external link] or the metrics exporter app with [StatsD](https://github.com/etsy/statsd/wiki) [external link] to receive, store and view this data over time.

You can also view data as a one-off snapshot using the Cloud Foundry CLI.

### Prometheus

The GOV.UK PaaS team maintains the API that Prometheus uses for free, which ensures that you can access all available metrics. You can configure Prometheus manually to filter out any unwanted metrics.

You must set up Prometheus to request metrics from the `https://metrics.cloud.service.gov.uk/metrics` API endpoint.

1. [Install Prometheus](https://prometheus.io/docs/prometheus/latest/getting_started/) [external link].

1. You must set up a bearer token so the API endpoint can authenticate your Prometheus request. We recommend that you use a bearer token file as it is easy to maintain. Set up an automated cron job to run the following command every 10 minutes:

	```
	cf oauth-token > BEARER_TOKEN_FILE
	```

	where `cf oauth-token` generates a bearer token and passes it to the bearer token file.

1. Configure Prometheus to read the bearer token from the bearer token file. Refer to the Prometheus [configuration documentation](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#ingress) [external link] for more information.

You can now check Prometheus to see if you are receiving metrics.

### Metrics exporter app with StatsD

To use the metrics exporter, you deploy it as an app on PaaS. The current metrics supported by this app are:

- CPU
- RAM
- disk usage data
- app crashes
- app requests
- app response times

#### Pre-requisites

Before you set up the metrics exporter app, you will need:

- a monitoring system to store the metrics with an accompanying [StatsD](https://github.com/etsy/statsd/wiki) [external link] endpoint set up
- a live Cloud Foundry account assigned to the spaces you want to receive metrics on

We recommend that this Cloud Foundry account:

- uses the [`SpaceAuditor` role](/orgs_spaces_users.html#space-auditor) as this role has the minimum permissions needed to meet the requirements of the metrics exporter app
- is separate to your primary Cloud Foundry account

To set up the metrics exporter app:

1. Clone the [https://github.com/alphagov/paas-metric-exporter](https://github.com/alphagov/paas-metric-exporter) repository.
1. [Push the metrics exporter app](/deploying_apps.html#deployment-overview) to Cloud Foundry without starting the app by running `cf push --no-start metric-exporter`.
1. Set the following mandatory environment variables in the metrics exporter app by running `cf set-env metric-exporter NAME VALUE`:

	|Name|Value|
	|:---|:---|
	|`API_ENDPOINT`|Use `https://api.cloud.service.gov.uk`|
	|`STATSD_ENDPOINT`|StatsD endpoint|
	|`USERNAME`|Cloud Foundry User|
	|`PASSWORD`|Cloud Foundry Password|

	You should use the `cf set-env` command for these mandatory variables as they contain secret information, and this method will keep them secure.

	You can also set environment variables by amending the manifest file. We recommend that you use this method for optional environment variables that do not contain secret information. Refer to the [https://github.com/alphagov/paas-metric-exporter](https://github.com/alphagov/paas-metric-exporter) repository for more information.

1. Start the metrics exporter app by running `cf start metric-exporter`.

You can now check your monitoring system to see if you are receiving metrics.

### Troubleshooting

If you are not receiving the metrics, check the Prometheus or metrics exporter app [logs](/monitoring_apps.html#logs). If you still need help, contact us by emailing [gov-uk-paas-support@digital.cabinet-office.gov.uk](mailto:gov-uk-paas-support@digital.cabinet-office.gov.uk).

### More about monitoring

For more information about monitoring apps, see [Monitoring the status of your service](https://www.gov.uk/service-manual/technology/monitoring-the-status-of-your-service) on the Service Manual.
