resource "aws_s3_bucket" "products" {
  bucket = "${local.account_id}-service-catalog-products"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "products" {
  bucket = aws_s3_bucket.products.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

resource "aws_s3_object" "product" {
  for_each = fileset("products/", "*.yaml")
  bucket = aws_s3_bucket.products.id
  key = "${each.value}"
  source = "products/${each.value}"
  etag = filemd5("products/${each.value}")
}

module "portfolio" {
  source                  = "./portfolio"
  portfolio_name          = "Nice Helpers Terraform"
  portfolio_description   = "Example Portfolio provided and managed by Terraform"
  portfolio_provider_name = "Terraform"
  products = [
    module.TrainingCostBudget.product_id,
    module.TrustRole.product_id,
    module.SimpleVPCAndLinux.product_id,
    module.AccountSpecificTrustRole.product_id]
  ou_names = ["Custom", "Training", "Juniors"]
  providers = {
    aws.shared = aws.shared
    aws.master = aws.master
   }
   depends_on = [
      module.TrainingCostBudget.product_id,
      module.TrustRole.product_id,
      module.SimpleVPCAndLinux.product_id,
      module.AccountSpecificTrustRole.product_id,
   ]
}

output "TrainingCostBudget" {
  value = module.TrainingCostBudget.product_id
}
output "TrustRole" {
  value = module.TrustRole.product_id
}
output "SimpleVPCAndLinux" {
  value = module.SimpleVPCAndLinux.product_id
}
output "AccountSpecificTrustRole" {
  value = module.AccountSpecificTrustRole.product_id
}

module "TrainingCostBudget" {
  source        = "./product_with_versions"
  product_name  = "TrainingCostBudget"
  product_owner = "Terraform"
  product_description   = "Training Budget with notifications at $5,$10,$25 and $45 for individual developer accounts."
  versions = [
    {
      name        = "v1.0"
      description  = "Training Budget"
      template     = "TrainingCostBudget.yaml"
      bucket       = aws_s3_bucket.products

    }
  ]
  providers = {
    aws.shared = aws.shared
    aws.master = aws.master
   }
}

module "TrustRole" {
  source        = "./product_with_versions"
  product_name  = "TrustRole"
  product_owner = "Terraform"
  product_description   = "A selection of different ways to establish a trust role to this account"
  versions = [
    {
      name        = "v1.0"
      description  = "Create Trusted Administrator Role to a specific account"
      template     = "AccountSpecificTrustRole.yaml"
      bucket       = aws_s3_bucket.products

    },
    {
      name        = "v1.1"
      description  = "Create Trusted ReadOnly Role to a specific account"
      template     = "AccountSpecificTrustRoleReadOnlyAccess.yaml"
      bucket       = aws_s3_bucket.products

    },
    {
      name        = "v1.2"
      description  = "Create Trusted Administrator Role to several accounts"
      template     = "MultiAccountTrustRole.yaml"
      bucket       = aws_s3_bucket.products
    },
    {
      name        = "v1.3"
      description  = "Create Trusted Administrator Role to a specific user in a specific account"
      template     = "UserSpecificTrustRole.yaml"
      bucket       = aws_s3_bucket.products

    }
    ]
  providers = {
    aws.shared = aws.shared
    aws.master = aws.master
   }
}

module "AccountSpecificTrustRole" {
  source        = "./product_with_versions"
  product_name  = "AccountSpecificTrustRole"
  product_owner = "Terraform"
  product_description   = "Create Trusted Role to a specific account"

  # this product is referred under TrustRole too. If the same version is resused, an error will occur.
  # name = "v1.0" ==> Package is in state FAILED, but must be in state AVAILABLE.
  versions = [
    {
      name        = "v1.0a"
      description  = "Create Trusted Role to a specific account"
      template     = "AccountSpecificTrustRole.yaml"
      bucket       = aws_s3_bucket.products

    }
  ]
  providers = {
    aws.shared = aws.shared
    aws.master = aws.master
   }
}

module "SimpleVPCAndLinux" {
  source        = "./product_with_versions"
  product_name  = "SimpleVPCAndLinux"
  product_owner = "Terraform"
  product_description   = "A series of different linux configurations"
  # the bucket is passed to the module to allow for
  # First product created in aws_servicecatalog_product
  # Following products are created in aws_servicecatalog_provisioning_artifact
  versions = [ 
    { 
      name = "v1.0"
      description = "VPC with Linux with public ssh access"
      template      = "simple-vpc-and-linux-instance.yaml"
      bucket        = aws_s3_bucket.products
    },
    { 
      name = "v1.1"
      description = "VPC with Linux with access through ssm"
      template      = "simple-vpc-and-linux-instance-with-ssm.yaml"
      bucket        = aws_s3_bucket.products
    },
    { 
      name = "v1.2"
      description = "VPC with Linux with access through ssm only"
      template      = "simple-vpc-and-linux-instance-with-ssm-only.yaml"
      bucket        = aws_s3_bucket.products
    }
    
    ]
  providers = {
    aws.shared = aws.shared
    aws.master = aws.master
   }
}

