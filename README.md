# Fury Kubernetes OCI

This repo contains all components necessary to deploy a High Availability Private Kubernetes Cluster on Oracle Cloud Infrastructure

## Requirements

All packages in this repository have following dependencies, for package
specific dependencies please visit the single package's documentation:

- OCI API KEY with Admin Permissions
- [Terraform](https://learn.hashicorp.com/terraform/getting-started/install.html) >= `v0.11.11`
- [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) >= `v1.11.7`

## Compatibility

| Distribution Version / Kubernetes Version | 1.13.X             | 1.14.X             | 1.15.X             | 1.16.X             |
|-------------------------------------------|:------------------:|:------------------:|:------------------:|:------------------:|
| v1.13.3                                   | :white_check_mark: |                    |                    |                    |

- :white_check_mark: Compatible
- :warning: Has issues
- :x: Incompatible

## License

For license details please see [LICENSE](LICENCE)