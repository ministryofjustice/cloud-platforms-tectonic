terraform {
  backend "s3" {
    bucket = "moj-kerin-terraform-tectonic-test"
    key    = "cluster-1/terraform.tfstate"
    region = "eu-west-1"
  }
}

provider "aws" {
  version = "1.1.0"
  region = "${var.region}"
}

resource "aws_key_pair" "tectonic" {
  key_name   = "${var.cluster_name}-tectonic"
  public_key = "${var.ssh_public_key}"
}

module "vpc" {
  # https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/1.9.1
  source  = "terraform-aws-modules/vpc/aws"
  version = "1.9.1"

  name = "${var.cluster_name}.${var.base_domain}"
  cidr = "${var.cidr}"

  azs             = "${var.azs}"
  private_subnets = "${var.private_subnets}"
  public_subnets  = "${var.public_subnets}"
  database_subnets  = "${var.database_subnets}"

  enable_nat_gateway = true
  enable_dns_hostnames = true # required for Tectonic's split-horizon DNS

  private_subnet_tags {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  public_subnet_tags {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}


module "kubernetes" {
  # https://registry.terraform.io/modules/coreos/kubernetes/aws/1.8.4-tectonic.3
  source  = "coreos/kubernetes/aws"
  version = "1.8.4-tectonic.3"

  tectonic_cluster_name = "${var.cluster_name}"
  tectonic_base_domain = "${var.base_domain}"
  tectonic_admin_email = "${var.tectonic_admin_email}"
  tectonic_admin_password = "${var.tectonic_admin_password}"

  tectonic_license_path = "${path.cwd}/creds/tectonic-license.txt"
  tectonic_pull_secret_path = "${path.cwd}/creds/config.json"

  tectonic_aws_ssh_key = "${aws_key_pair.tectonic.key_name}"
  tectonic_aws_external_vpc_id = "${module.vpc.vpc_id}"
  tectonic_aws_external_master_subnet_ids = "${module.vpc.public_subnets}"
  tectonic_aws_external_worker_subnet_ids = "${module.vpc.private_subnets}"
}
