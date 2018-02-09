# Deploy a backing or routing service

Many 12-factor applications rely on backing services such as a database, an email delivery service or a monitoring system. Routing services can be used to proxy and perform preprocessing on application requests such as caching, rate limiting or authentication.

In Cloud Foundry, backing and routing services are referred to as 'services' and are available through the Cloud Foundry ``cf marketplace`` command. GOV.UK PaaS enables you to create a backing service and bind it to your app. The available backing services are detailed below.

## PostgreSQL

PostgreSQL is an object-relational database management system. It is open source and designed to be extensible; currently the postgis and uuid-ossp extensions are enabled.

### Set up a PostgreSQL service

To set up a PostgreSQL service:

1. Run the following code in the command line to see what plans are available for PostgreSQL:

    `cf marketplace -s postgres`

    Here is an example of the output you will see (the exact plans will vary):

    ```
    service plan             description                                                                                                                                                       free or paid
    M-dedicated-X.X          20GB Storage, Dedicated Instance, Max 500 Concurrent Connections. Postgres Version X.X. DB Instance Class: db.m4.large.                                           paid
    M-HA-dedicated-X.X       20GB Storage, Dedicated Instance, Highly Available, Max 500 Concurrent Connections. Postgres Version X.X. DB Instance Class: db.m4.large.                         paid
    ...
    Free                     5GB Storage, NOT BACKED UP, Dedicated Instance, Max 50 Concurrent Connections. Postgres Version X.X. DB Instance Class: db.t2.micro.                              free
    ```

    The syntax in this output is explained in the following table:

    |Syntax|Meaning|
    |:---|:---|
    |`HA`|High availability|
    |`ENC`|Encrypted|
    |`X.X`|Version number|
    |`S / M / L / XL`|Size of instance|

    More information can be found in the [PostgresSQL plans](/#postgresql-plans) section.

1. Run the following code in the command line:

    `cf create-service postgres PLAN SERVICE_NAME`

    where `PLAN` is the plan you want, and `SERVICE_NAME` is a unique descriptive name for this instance of the service. For example:

    `cf create-service postgres M-dedicated-9.5 my-pg-service`

    You should use a high-availability (`HA`) encrypted plan for production apps.

1. It will take between 5 and 10 minutes to set up the service instance. To check its progress, run:

    `cf service SERVICE_NAME`

    for example:

    `cf service my-pg-service`

    The service is set up when the `cf service SERVICE_NAME` command returns a `create succeeded` status. Here is an example of the output you will see:

    ```
    Service instance: my-pg-service
    Service: postgres
    Bound apps:
    Tags:
    Plan: M-dedicated-9.5
    Description: AWS RDS PostgreSQL service
    Documentation url: https://aws.amazon.com/documentation/rds/
    Dashboard:

    Last Operation
    Status: create succeeded
    Message: DB Instance 'rdsbroker-9f053413-97a5-461f-aa41-fe6e29db323e' status is 'available'
    Started: 2016-08-23T15:34:41Z
    Updated: 2016-08-23T15:42:02Z
    ```

### Bind a PostgreSQL service to your app

You must bind your app to the PostgreSQL service to be able to access the database from the app.

1. Run the following code in the command line:

    `cf bind-service APPLICATION SERVICE_NAME`

    where `APPLICATION` is the name of a deployed instance of your application (exactly as specified in your manifest or push command) and `SERVICE_NAME` is a unique descriptive name for this service instance. For example:

    `cf bind-service my-app my-pg-service`

1. If the app is already running, you should restage the app to make sure it connects:

    `cf restage APPLICATION`

1. To confirm that the service is bound to the app, run:

    `cf service SERVICE_NAME`

    and check the `Bound apps:` line of the output.

    ```
    Service instance: my-pg-service
    Service: postgres
    Bound apps: my-app
    Tags:
    Plan: M-dedicated-9.5
    Description: AWS RDS PostgreSQL service
    Documentation url: https://aws.amazon.com/documentation/rds/
    Dashboard:

    Last Operation
    Status: create succeeded
    Message: DB Instance 'rdsbroker-9f053413-97a5-461f-aa41-fe6e29db323e' status is 'available'
    Started: 2016-08-23T15:34:41Z
    Updated: 2016-08-23T15:42:02Z
    ```

1. Run `cf env APPNAME` to see the app's environment variables and confirm that the [VCAP_SERVICES environment variable](/#system-provided-environment-variables) contains the correct service connection details.

    Your app must make a [TLS](https://en.wikipedia.org/wiki/Transport_Layer_Security) connection to the service. Some libraries use TLS by default, but others will need to be explicitly configured.

    GOV.UK PaaS will automatically parse the ``VCAP_SERVICES`` [environment variable](/#system-provided-environment-variables) to get details of the service and then set the `DATABASE_URL` variable to the first database found.

    If your app writes database connection errors to `STDOUT` or `STDERR`, you can view recent errors with ``cf logs APPNAME --recent``. See the section on [Logs](#logs) for details.

### Connect to a PostgreSQL service from your local machine

We have created the [Conduit](#conduit) plugin to simplify the process of connecting your local machine to a PostgreSQL service. To install this plugin, run the following code from the command line:

`cf install-plugin conduit`

Once the plugin has finished installing, you can use it by running:

`cf conduit --help`

Refer to the [Conduit readme file](https://github.com/alphagov/paas-cf-conduit/blob/master/README.md) [external link] for more information on how to use the plugin.

### Upgrade PostgreSQL service plan

You can upgrade your service plan (for example, from free to paid high availability) by running `cf update-service` in the command line:

```
cf update-service SERVICE_NAME -p NEW_PLAN_NAME
```

where `SERVICE_NAME` is a unique descriptive name for this instance of the service, and `NEW_PLAN_NAME` is the name of your new plan. For example:

```
cf update-service my-pg-service -p S-HA-dedicated-9.5
```

The plan upgrade will begin immediately and will usually be completed within about an hour. You can check the status of the change by running the `cf services` command.

You can also [queue a plan upgrade](/#queue-a-migration-postgresql) to happen during a maintenance window to minimise service interruption.

Downgrading service plans is not currently supported.

### Unbind a PostgreSQL service from your app

You must unbind the PostgreSQL service before you can delete it. To unbind the PostgreSQL service, run the following code in the command line:

`cf unbind-service APPLICATION SERVICE_NAME`

where `APPLICATION` is the name of a deployed instance of your application (exactly as specified in your manifest or push command) and `SERVICE_NAME` is a unique descriptive name for this instance of the service, for example:

`cf unbind-service my-app my-pg-service`

If you unbind your services from your app but do not delete them, the services will persist even after your app is deleted, and you can re-bind or re-connect to them in future.

### Delete a PostgreSQL service

Once the PostgreSQL service has been unbound from your app, you can delete it. Run the following code in the command line:

`cf delete-service SERVICE_NAME`

where `SERVICE_NAME` is a unique descriptive name for this instance of the service.

Type `yes` when asked for confirmation.

### PostgreSQL plans

Each service in the marketplace has multiple plans that vary by availability, storage capacity and encryption.

#### Paid plans - PostgreSQL

Some service plans are paid and we can potentially bill you based on your service usage.

New organisations cannot access paid plans by default. Enabling this access is controlled by an organisation's [quota](/#quotas) settings.

If paid plans are not enabled, when you try to use a paid service you will receive an error stating “service instance cannot be created because paid service plans are not allowed”. One of your [Org Managers](/#org-manager) must contact us at [gov-uk-paas-support@digital.cabinet-office.gov.uk](mailto:gov-uk-paas-support@digital.cabinet-office.gov.uk) to request that we enable paid services.

There is a free plan available with limited storage which should only be used for development or testing, but __not production__.

#### Encrypted plans - PostgreSQL

Plans with `ENC` in the name include encryption at rest of the database storage. This means that both the data on the disk and in snapshots is encrypted.

You should use an encrypted plan for production services or services that use real data.

Once you've created a service instance, you can't enable or disable encryption.

#### High availability plans - PostgreSQL

We recommend you use a high availability plan (`HA`) for your PostgreSQL apps. These plans use Amazon RDS Multi-AZ instances, which are designed to be 99.95% available (see [Amazon's SLA](https://aws.amazon.com/rds/sla/) for details).

When you use a high availability plan, Amazon RDS provides a hot standby service for failover in the event that the original service fails.

Refer to the [Amazon RDS documentation on the failover process](http://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.MultiAZ.html#Concepts.MultiAZ.Failover) for more information.

You should test how your app deals with a failover to make sure you are benefiting from the high availability plan. Contact us at [gov-uk-paas-support@digital.cabinet-office.gov.uk](mailto:gov-uk-paas-support@digital.cabinet-office.gov.uk) to arrange for us to trigger a failover for you.

#### Read replicas - PostgreSQL

Amazon RDS has the capability to provide a read-only copy of your database known as a read replica. This can be useful for performance, availability or security reasons.

Refer to the [Amazon RDS documentation on read replicas](https://aws.amazon.com/rds/details/read-replicas/) for more information.

GOV.UK PaaS doesn't currently support read replicas, but if you think you would find them useful, please contact us at [gov-uk-paas-support@digital.cabinet-office.gov.uk](mailto:gov-uk-paas-support@digital.cabinet-office.gov.uk), providing details of your use case.

### PostgreSQL maintenance & backups

#### PostgreSQL maintenance times

Each PostgreSQL service you create will have a randomly-assigned weekly 30 minute maintenance window, during which there may be brief downtime. Select a high availability (`HA`) plan to minimise this downtime. Minor version upgrades (for example from 9.4.1 to 9.4.2) are applied during this maintenance window.

Contact us at [gov-uk-paas-support@digital.cabinet-office.gov.uk](mailto:gov-uk-paas-support@digital.cabinet-office.gov.uk) to find out the default time of your maintenance window. Window start times will vary from 22:00 to 06:00 UTC.

You can set your own maintenance window by running `cf update-service` in the command line and setting the `preferred_maintenance_window` custom parameter:

```
cf update-service postgres PLAN SERVICE_NAME -c '{"preferred_maintenance_window": "START_DAY:START_TIME-END_DAY:END_TIME"}'
```

where `SERVICE_NAME` is a unique, descriptive name for this service instance and `PLAN` is the plan you have, for example:

```
cf update-service postgres M-dedicated-9.5 my-pg-service -c '{"preferred_maintenance_window": "Tue:04:00-Tue:04:30"}'
```

For more information on maintenance times, refer to the [Amazon RDS Maintenance documentation](http://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_UpgradeDBInstance.Maintenance.html) [external link].

#### Queue a migration - PostgreSQL

Migrating to a new plan may cause interruption to your service instance. To minimise interruption, you can queue the change to begin during a maintenance window by running the following code in the command line:

```
cf update-service postgres SERVICE_NAME -p PLAN -c '{"apply_at_maintenance_window": true, "preferred_maintenance_window": "START_DAY:START_TIME-END_DAY:END_TIME"}'
```

where `SERVICE_NAME` is a unique, descriptive name for this service instance and `PLAN` is the plan you want, for example:

```
cf update-service postgres my-pg-service -p S-HA-dedicated-9.5 -c '{"apply_at_maintenance_window": true, "preferred_maintenance_window": "wed:03:32-wed:04:02"}'
```

Passing the `preferred_maintenance_window` parameter will alter the default maintenance window for any future maintenance events required for the database instance.

#### PostgreSQL service backup

The data stored within any PostgreSQL service you create is backed up using the standard Amazon RDS backup system if you are using a paid plan. Your data is not backed up if you are using the free plan.

Backups are taken nightly at some time between 22:00 and 06:00 UTC. Data is retained for 7 days.

There are two ways you can restore data to an earlier state:

1. You can restore to the latest snapshot yourself. See [Restoring a PostgreSQL service snapshot](/#restoring-a-postgresql-service-snapshot) for details.

1. We can manually restore to any point from 5 minutes to 7 days ago, with a resolution of one second. Data can be restored to a new PostgreSQL service instance running in parallel, or it can replace the existing service instance.

    To arrange a manual restore, contact us at [gov-uk-paas-support@digital.cabinet-office.gov.uk](mailto:gov-uk-paas-support@digital.cabinet-office.gov.uk). We will need approval from your organization manager if restoring will involve overwriting data.

Note that data restore will not be available in the event of an RDS outage that affects the entire Amazon availability zone.

For more details about how the RDS backup system works, see [Amazon's DB Instance Backups documentation](http://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Overview.BackingUpAndRestoringAmazonRDSInstances.html) [external page].

#### Restoring a PostgreSQL service snapshot

You can create a copy of any existing PostgreSQL service instance using the latest snapshot of the RDS instance. These snapshots are taken during [the PostgreSQL nightly backups](#postgresql-service-backup).

This can be useful if you want to clone a production database to be used for testing or batch processing.

To restore from a snapshot:

 1. Get the global unique identifier (GUID) of the existing instance by running the following code in the command line:

    `cf service SERVICE_NAME --guid`

    where `SERVICE_NAME` is the name of the PostgreSQL service instance you want to copy. For example:

    `cf service my-pg-service --guid`

    This returns a `GUID` in the format `XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX`, for example `32938730-e603-44d6-810e-b4f12d7d109e`.

 2. Trigger the creation of a new service based on the snapshot by running:

    `cf create-service postgres PLAN NEW_SERVICE_NAME -c '{"restore_from_latest_snapshot_of": "GUID"}'`

    where `PLAN` is the plan used in the original instance (you can find this out by running `cf service SERVICE_NAME`), and `NEW_SERVICE_NAME` is a unique, descriptive name for this new instance. For example:

    `cf create-service postgres M-dedicated-9.5 my-pg-service-copy  -c '{"restore_from_latest_snapshot_of": "32938730-e603-44d6-810e-b4f12d7d109e"}'`

 3. It takes between 5 to 10 minutes for the new service instance to be set up. To find out its status, run:

    `cf service NEW_SERVICE_NAME`

    for example:

    `cf service my-pg-service-copy`

 4. The new instance is set up when the `cf service NEW_SERVICE_NAME` command returns a `create succeeded` status. See [Set up a PostgreSQL service](#set-up-a-postgresql-service) for more details.

 This feature has the following limitations:

  * You can only restore the most recent snapshot from the latest nightly backup
  * You cannot restore from a service instance that has been deleted
  * You must use the same service plan for the copy as for the original service instance
  * You must create the new service instance in the same organisation and space as the original. This is to prevent unauthorised access to data between spaces. If you need to copy data to a different organisation and/or space, you can use [`pg_dump`](https://www.postgresql.org/docs/9.5/static/backup-dump.html) and [`pg_restore`](https://www.postgresql.org/docs/9.5/static/app-pgrestore.html) via [SSH tunnels](#creating-tcp-tunnels-with-ssh).


## MySQL

MySQL is an open source relational database management system that uses Structured Query Language (SQL) and is backed by Oracle.

## MongoDB

MongoDB is an open source cross-platform document-oriented database program. It uses JSON-like documents with schemas, and is often used for content management such as articles on [GOV.UK](https://www.gov.uk/). This is an early version of the service that is available on request so that we can get feedback, and we will make you aware of any constraints in its use at that time.

## Redis

Redis is an open source in-memory data store that can be used as a database cache or message broker. This is an early version of the service that is available on request so that we can get feedback, and we will make you aware of any constraints in its use at that time.

## Elasticsearch

Elasticsearch is an open source full text RESTful search and analytics engine that allows you to store and search data. This is an early version of the service that is available on request so that we can get feedback, and we will make you aware of any constraints in its use at that time.

## Services and plans

Each service in the marketplace can have multiple plans available with different characteristics. For example, there are different PostgreSQL plans which vary by availability, storage capacity and encryption.

Users can also define their own external services that are not available in the marketplace by using [User-Provided Service Instances](/#user-provided-service-instance).

### Paid service plans

Some service plans are paid; you can potentially be billed by us based on your usage of the service. There is a free plan available with limited storage which should only be used for development or testing, not production.

By default, access to paid plans is not enabled for a new organisation. Whether this is enabled or not is controlled by your [organisation's quota settings](/#quotas).

If paid plans are not enabled, when you try to use a paid service you will receive an error stating "service instance cannot be created because paid service plans are not allowed". One of your [Org Managers](https://docs.cloud.service.gov.uk/#org-manager) must contact us at [gov-uk-paas-support@digital.cabinet-office.gov.uk](mailto:gov-uk-paas-support@digital.cabinet-office.gov.uk) to request that we enable paid services.

### Accessing services

Your app can find out what backing services are available, and obtain credentials for the services, by parsing the VCAP_SERVICES [environment variable](/#environment-variables).

### User-provided service instance

Cloud Foundry enables tenants to define a [user-provided service instance](https://docs.cloudfoundry.org/devguide/services/user-provided.html) [external link]. They can be used to deliver service credentials to an application, and/or to trigger streaming of application logs to a syslog compatible consumer. Once created, user-provided service instances behave like service instances created through the marketplace.

### Future services

If you need a particular backing service that we don't yet support, please let us know at [gov-uk-paas-support@digital.cabinet-office.gov.uk](mailto:gov-uk-paas-support@digital.cabinet-office.gov.uk).
