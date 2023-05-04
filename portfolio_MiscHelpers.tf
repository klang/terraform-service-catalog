locals {
    MiscHelpers_launch_roles = merge(
      jsondecode(local.launch_role_TrainingCostBudget),
      jsondecode(local.launch_role_SimpleVPCAndLinux))
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
    launch_roles     = local.MiscHelpers_launch_roles
    portfolio_ou_ids = module.MiscHelpers.ou_ids
    region           = local.region
    providers = {
      aws.shared = aws.shared
      aws.master = aws.master
    }
}