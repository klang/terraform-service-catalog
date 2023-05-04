locals {
    NiceHelpers_launch_roles = merge(
      jsondecode(local.launch_role_TrainingCostBudget),
      jsondecode(local.launch_role_TrustRole),
      jsondecode(local.launch_role_AccountSpecificTrustRole),
      jsondecode(local.launch_role_SimpleVPCAndLinux))
}

module "NiceHelpers" {
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

module "ServiceCatalogAccessNiceHelpers" {
    source           = "./service_catalog_access_stackset"
    portfolio_name   = module.NiceHelpers.name
    launch_roles     = local.MiscHelpers_launch_roles
    portfolio_ou_ids = module.NiceHelpers.ou_ids
    region           = local.region
    providers = {
      aws.shared = aws.shared
      aws.master = aws.master
    }
}