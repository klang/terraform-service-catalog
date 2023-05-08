locals {
    NiceHelpers_null_template = templatefile(
        "${path.module}/templates/no-new-launch-roles.tftpl", {PortfolioName = "NiceHelpers"}
    )
    NiceHelpers_no_new_launch_roles = jsondecode(local.MiscHelpers_null_template)
    # if NiceHelpers are present, then these launch roles are created, with names:
    # - ServiceCatalogLaunchRoleTrainingCostBudget
    # - ServiceCatalogLaunchRoleTrustRole
    # - ServiceCatalogLaunchRoleAccountSpecificTrustRole
    # - ServiceCatalogLaunchRoleSimpleVPCAndLinux
    # and can not be added via ServiceCatalogAccess elsewhere
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
  ou_names = ["Custom", "Juniors"] #  "Training"
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
    launch_roles     = local.NiceHelpers_launch_roles
    create_access    = true
    portfolio_ou_ids = module.NiceHelpers.ou_ids
    region           = local.region
    providers = {
      aws.shared = aws.shared
      aws.master = aws.master
    }
}