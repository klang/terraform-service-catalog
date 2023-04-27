
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.7.0"
      configuration_aliases = [ aws.shared, aws.master ]
    }
  }
}

data "aws_organizations_organization" "org" {
  provider = aws.master
}

data "aws_organizations_organizational_units" "ou" {
  provider = aws.master
  parent_id = data.aws_organizations_organization.org.roots[0].id
}

# based on the ou_names, we use the master account to look up the ou's and make a list of ou_arns to be used later
locals {
  ou_arns = [ for ou in data.aws_organizations_organizational_units.ou.children : ou.arn if contains(var.ou_names, ou.name) ]
}

resource "aws_servicecatalog_portfolio" "portfolio" {
    provider      = aws.shared
    name          = var.portfolio_name
    description   = var.portfolio_description
    provider_name = var.portfolio_provider_name
} 

resource "aws_servicecatalog_product_portfolio_association" "product" {
    provider     = aws.shared
    count        = length(var.products)
    portfolio_id = aws_servicecatalog_portfolio.portfolio.id
    product_id   = var.products[count.index]
}

# requires
# TF_CLI_ARGS_apply="-parallelism=1"
resource "aws_servicecatalog_portfolio_share" "organizational_units" {
    provider     = aws.shared
    count        = length(local.ou_arns)
    principal_id = local.ou_arns[count.index]
    portfolio_id = aws_servicecatalog_portfolio.portfolio.id
    type         = "ORGANIZATIONAL_UNIT"
}