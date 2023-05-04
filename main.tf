/* module "portfolio" {
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
} */

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
  launch_role_policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [
    {
        Action = [
        "budgets:*",
        ]
        Effect   = "Allow"
        Resource = "*"
    },
    ]
})
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
  launch_role_policy_document = jsonencode({
      Version = "2012-10-17"
      Statement = [
      {
          Action = [
          "iam:*",
          ]
          Effect   = "Allow"
          Resource = "*"
      },
      ]
  })  
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
  launch_role_policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [
    {
        Action = [
        "iam:*",
        ]
        Effect   = "Allow"
        Resource = "*"
    },
    ]
  })
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
  launch_role_policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
  providers = {
    aws.shared = aws.shared
    aws.master = aws.master
  }
}

module "MiscHelpers" {
  source                  = "./portfolio"
  portfolio_name          = "Misc Helpers Terraform"
  portfolio_description   = "Extra Portfolio provided and managed by Terraform"
  portfolio_provider_name = "Terraform"
  products = [
    module.TrainingCostBudget.product_id,
    module.SimpleVPCAndLinux.product_id,
  ]
  ou_names = ["Juniors"]
  providers = {
    aws.shared = aws.shared
    aws.master = aws.master
   }
   depends_on = [
      module.TrainingCostBudget.product_id,
      module.SimpleVPCAndLinux.product_id,
   ]
}

module "ServiceCatalogAccessMiscHelpers" {
    source           = "./service_catalog_access_stackset"
    portfolio_name   = module.MiscHelpers.name
    launch_roles     = merge(
      jsondecode(local.launch_role_TrainingCostBudget),
      jsondecode(local.launch_role_SimpleVPCAndLinux))
    portfolio_ou_ids = module.MiscHelpers.ou_ids
    region           = local.region
    providers = {
      aws.shared = aws.shared
      aws.master = aws.master
    }
}

