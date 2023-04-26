# -*- mode: json -*-

#variable "environment" { default = "prod"}

locals {
  env = {
    default_account_alias                = "iam"
    default_region                      = "eu-west-1"
    default_account_id                   = "055524301700"

    training_account_alias               = "training"
    training_region                      = "eu-west-1"
    training_account_id                  = "703965850448"

    shared-services_account_alias        = "shared-services"
    shared-services_region               = "eu-west-1"
    shared-services_account_id           = "940740948575"


  }
  master_account_id = "588412859260"
  account_alias = "${lookup(local.env, "${terraform.workspace}_account_alias")}"
  region        = "${lookup(local.env, "${terraform.workspace}_region")}"
  account_id    = "${lookup(local.env, "${terraform.workspace}_account_id")}"
}