terraform {
  required_providers {
    kubernetes = {
      version = "2.18.1"
    }
    vault     = {
      version = "3.13.0"
    }
  }
}

provider "kubernetes" {
  config_path = "kubeconfig"
}

provider "vault" {
}

data "kubernetes_service_account" "vault" {
  metadata {
    name      = "vault"
    namespace = "vault"
  }
}

#data "kubernetes_secret" "vault" {
#  metadata {
#    name      = data.kubernetes_service_account.vault.default_secret_name
#    namespace = "vault"
#  }
#}

resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
}

#output "kubernetes_vault" {
#  value = data.kubernetes_secret.vault.type
#}


resource "vault_kubernetes_auth_backend_config" "example" {
  backend             = vault_auth_backend.kubernetes.path
  kubernetes_host     = "https://172.18.0.3:6443"
}

resource "vault_kubernetes_auth_backend_role" "demo" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "demo"
  bound_service_account_names      = ["app"]
  bound_service_account_namespaces = ["demo"]
  token_ttl                        = 3600
  token_policies                   = ["default", "demo"]
}

data "vault_policy_document" "demo" {
  rule {
    path         = "secret/*"
    capabilities = ["read", "list"]
    description  = "allow read access to secret/*"
  }
  rule {
    path         = "kv"
    capabilities = ["list"]
    description  = "allow read access to /kv/demo"
  }
}

resource "vault_policy" "demo" {
  name   = "demo"
  policy = data.vault_policy_document.demo.hcl
}

