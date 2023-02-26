create-cluster-kind:
	kind create cluster --config kind-config.yml --name vault
	kind get kubeconfig --name vault > kubeconfig

destroy-kind:
	kind delete cluster --name vault

install:
	furyctl vendor

init:
	terraform init

plan:
	terraform plan

apply:
	terraform apply

run:
	terraform apply
	terraform output vault_backend_conf > config/backend.hcl
	terraform output vault_autounseal_conf > config/autounseal.hcl

output:
	terraform output --raw vault_backend_conf > config/backend.hcl
	terraform output --raw vault_autounseal_conf > config/autounseal.hcl


kustomize:
	kustomize build . | kubectl apply -f -

expose:
	@echo execute "make demo-2" to initialize vault
	kubectl port-forward -n vault svc/vault 8200:8200 &

vault-init: expose
	VAULT_ADDR=http://127.0.0.1:8200 vault operator init
	@echo
	@echo TAKE NOTE OF THE GENERATED KEYS/TOKEN
	@echo
	@echo EXECUTE THE FOLLOWING, using the Initial Root Token as VAULT_TOKEN
	@echo export VAULT_ADDR=http://127.0.0.1:8200
	@echo export VAULT_TOKEN=

vault-inject-secrets: expose
	vault policy write app - <<EOF
	path "secret*" {
		capabilities = ["read"]
	}
	EOF

#launch this inside a vault node
vault-inject-kubernetes-auth:
	vault auth enable kubernetes
	vault write auth/kubernetes/config \
		token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
		kubernetes_host="https://$${KUBERNETES_PORT_443_TCP_ADDR}:443" \
		kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt

vault-kubernetes-app:
	vault write auth/kubernetes/role/myapp \
		bound_service_account_names=app \
		bound_service_account_namespaces=demo \
		policies=app \
		ttl=1h

vault-kv-helloworld:
	vault secrets enable -path=secret/ kv
	vault kv put secret/helloworld username=app password=changeme

deploy-app:
	kubectl apply -f demo/demo.yaml

deploy-patch-basic:
	kubectl patch deployment app -n demo --patch "$(cat demo/patches/patch-basic-annotations.yaml)"

deploy-patch-template:
	kubectl patch deployment app -n demo --patch "$(cat demo/patches/patch-template-annotations.yaml)"

destroy:
	kubectl delete -k . || exit 0
	terraform destroy || exit 0

demo-1: install init run kustomize expose
demo-2: vault-init
