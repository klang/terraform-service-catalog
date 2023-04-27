terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.7.0"
      configuration_aliases = [ aws.shared, aws.master ]
    }
  }
}

resource "aws_servicecatalog_product" "product_version" {
    provider = aws.shared
    name  = var.product_name
    owner = var.product_owner
    type  = "CLOUD_FORMATION_TEMPLATE"
    description = local.product_description

    provisioning_artifact_parameters {
        type = "CLOUD_FORMATION_TEMPLATE"
        description = local.version_description
        disable_template_validation = var.disable_template_validation
        name = var.version_name
        template_url = var.template_url
    }

    tags = {
        Creator = "Terraform"
    }
}