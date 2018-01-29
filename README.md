# cloud-platforms-tectonic
Terraform resources for Tectonic Kubernetes cluster

## Prequisites
- Install [Terraform v0.11.2](https://www.terraform.io/)
- Install [git-crypt](https://www.agwa.name/projects/git-crypt/)
- Ensure you have an AWS access key and secret in `~/.aws/credentials`
- Check out this repo
- Run `$ terraform init`

## git-crypt

The directories `creds`, `generated` and `identity`, and the `terraform.tfvars` file contain sensitive values, and are encrypted with `git-crypt`, so your GPG keys must be added to the keychain to decrypt.

## First run - creating cluster
Due to an [open issue in Terraform](https://github.com/hashicorp/terraform/issues/12570), resources must be created in two phases:

- `$ terraform apply -target=module.vpc`
- `$ terraform apply -target=module.kubernetes`

## Working with existing cluster
Once resources have been created for the first time, subsequent modifications can be applied in a single phase:

- `$ terraform apply`

## Identity / authentication config
Tectonic ships with [CoreOS Dex](https://github.com/coreos/dex) as an identity broker, which can be configured to use federated identity providers. A configuration snippet is included in the `identity/` directory, which can be applied like so (once your local `kubectl` install is configured to access the cluster):

- `$ kubectl edit configmaps tectonic-identity --namespace=tectonic-system` - add the YAML snippet to the `config.yaml` block
- `$ kubectl delete pods -l k8s-app=tectonic-identity -n tectonic-system ` - delete and recreate running Dex containers with the new config

## RBAC
The `rbac/webops-cluster-admin.yml` creates a ClusterRoleBinding resource to map members of the `WebOps` Github team to Kubernetes cluster admins. This can be created with:

- `$ kubectl apply -f rbac/webops-cluster-admin.yml`
