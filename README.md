# fury-kubernetes-vault

Fury Kubernetes Vault deployment

## Vault Packages

Following packages are included in Fury Kubernetes Vault katalog:

- [Vault](katalog/single): Vault is a tool for securely accessing
  secrets. A secret is anything that you want to tightly control
  access to, such as API keys, passwords, or certificates. Version: **1.12.3**
- [Vault Agent Injector](katalog/sidecar-injector): Vault Agent Injector
  is a mutating webhook that automatically injects Vault Agent containers
  into pods. Version: **1.2.0**

Following packages are included in Fury Kubernetes Vault modules:

- [aws/dynamo](modules/aws/dynamo): Creates an AWS DynamoDB table with an user
  with permissions to manage the table.
- [aws/kms](modules/aws/kms): Creates KMS keys with an user with permissions to
  the key to encrypt and decrypt secrets.
- [vault](modules/vault): Creates
  some [`vault_kubernetes_auth_backend_role`](https://www.terraform.io/docs/providers/vault/r/kubernetes_auth_backend_role.html)
  to be used in a Kubernetes cluster.

## Compatibility

| Module Version / Kubernetes Version | 1.19.X | 1.20.X |       1.21.X       |       1.22.X       |       1.23.X       |       1.24.X       |       1.25.X       |
|-------------------------------------|:------:|:------:|:------------------:|:------------------:|:------------------:|:------------------:|:------------------:|
| v1.0.0                              |        |        | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: |

- :white_check_mark: Compatible
- :warning: Has issues
- :x: Incompatible
