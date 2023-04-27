terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.7.0"
      configuration_aliases = [ aws.shared, aws.master ]
    }
  }
}

# observe that the first product is referred to by the s3:// url, while the following use https://
# This is an inconsistency in the servicecatalog interface that requires this 

resource "aws_servicecatalog_provisioning_artifact" "this" {
  provider = aws.shared
  count = length(var.versions) - 1
  product_id   = aws_servicecatalog_product.this.id
  type = "CLOUD_FORMATION_TEMPLATE"
  description = var.versions[count.index + 1 ].description 
  disable_template_validation = var.disable_template_validation
  name = var.versions[count.index + 1].name
  template_url = "https://${var.versions[count.index +1].bucket.bucket_regional_domain_name}/${var.versions[count.index + 1].template}"
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
      #template_url = var.versions[0].template_url
      #template_url = "s3://${var.versions[0].bucket.bucket}/${var.versions[0].template}"
      template_url = "https://${var.versions[0].bucket.bucket_regional_domain_name}/${var.versions[0].template}"
  }
  
  tags = {
      Creator = "Terraform"
  }
}