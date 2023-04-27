terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.7.0"
      configuration_aliases = [ aws.shared, aws.master ]
    }
  }
}

# we grab the first version of the product and use it in the `provisioning_artifact_parameters` the rest are created as `aws_servicecatalog_provisioning_artifact`'s
resource "aws_servicecatalog_provisioning_artifact" "this" {
  provider = aws.shared
  count = length(var.versions) - 1
  product_id   = aws_servicecatalog_product.this.id
  type = "CLOUD_FORMATION_TEMPLATE"
  description = var.versions[count.index + 1 ].description 
  disable_template_validation = var.disable_template_validation
  name = var.versions[count.index + 1].name
  template_url = "https://${var.versions[count.index + 1].bucket.bucket_regional_domain_name}/${var.versions[count.index + 1].template}"
  timeouts {
    create = "3m"
    delete = "3m"
    update = "3m"
    read   = "3m"
  }
}

resource "aws_servicecatalog_product" "this" {
  provider = aws.shared
  name  = var.product_name
  owner = var.product_owner
  type  = "CLOUD_FORMATION_TEMPLATE"
  description = var.product_description

  provisioning_artifact_parameters {
      type = "CLOUD_FORMATION_TEMPLATE"
      description = var.versions[0].description 
      disable_template_validation = var.disable_template_validation
      name = var.versions[0].name
      template_url = "https://${var.versions[0].bucket.bucket_regional_domain_name}/${var.versions[0].template}"
  }
  
  tags = {
      Creator = "Terraform"
  }
}