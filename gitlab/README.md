# GitLab on AWS & Kubernetes - An opinionated installation

This module is a highly opinionated installation of *GitLab* which makes use of the official 
[GitLab Helm Chart](https://docs.gitlab.com/charts/) to install and configure GitLab on an arbitrary Kubernetes cluster
using [Terraform](https://www.terraform.io/), and creating all the necessary external dependencies in a provided AWS 
account, achieving a high level of automation and easy maintainability.

## Structure

There are two directories in the repository:
* *examples* - containing an example of invocation from terraform
* *gitlab* - the terraform module that should be reusable across environments

## AWS Specific Configuration

GitLab offers the possibility to disable certain dependency pods and utilize externally hosted services instead.
Such services are:
* Object Storage - Instead of MinIO which is not production ready, S3 buckets can be utilized
* PostgreSQL - Instead of a statefulset, AWS RDS Postgres will be used
* Redis - Instead of a redis pod, AWS ElastiCache will be used // TODO - not yet implemented

The module will take create and maintain the above services by with Terraform, there is no manual configuration needed. 

## OmniAuth Configuration
There is support for confiugring multiple identity providers with GitLab's OmniAuth.

Currently the module supports configuring a single SAML provider.

For full documentation of OmniAuth see https://docs.gitlab.com/ee/integration/saml.html.   

## Used Terraform Providers
* [AWS](https://www.terraform.io/docs/providers/aws/index.html) - Creating AWS resources
* [Kubernetes](https://www.terraform.io/docs/providers/kubernetes/index.html) - Creating namespaces, secrets
* [Helm](https://www.terraform.io/docs/providers/helm/index.html) - Performing the release
* [Random](https://www.terraform.io/docs/providers/random/index.html) - Creating IDs and passwords

# Operating considerations

### Backups
GitLab has utilities for backing up and restoring an installation.
For a generic description of this functionality check [this](https://docs.gitlab.com/ee/raketasks/backup_restore.html) link.

For a kubernetes specific guide see 
[this](https://gitlab.com/gitlab-org/charts/gitlab/blob/master/doc/backup-restore/backup.md#backing-up-a-gitlab-installation) 
link.

> **WARNING**
>
> Make sure to back up the rails secret separately since it is not included in the backup tarball.
> Recommended to keep it separately from your backup, e.g. 1Password or similar.
>

### Kubernetes PVC related operations

Storage changes after installation need to be manually handled by your cluster administrators. Automated management of 
these volumes after installation is not handled by the GitLab chart.

For more information see [this](https://docs.gitlab.com/charts/advanced/persistent-volumes/) link.
