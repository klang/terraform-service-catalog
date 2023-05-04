locals {
    MiscHelpers_null_template = templatefile(
        "${path.module}/templates/no-new-launch-roles.tftpl", {PortfolioName = "MiscHelpers"}
    )
    MiscHelpers_no_new_launch_roles = jsondecode(local.MiscHelpers_null_template)
    # if NiceHelpers are present, then these launch roles are already created, with names:
    # - ServiceCatalogLaunchRoleTrainingCostBudget
    # - ServiceCatalogLaunchRoleSimpleVPCAndLinux
    MiscHelpers_launch_roles = merge(
      jsondecode(local.launch_role_TrainingCostBudget),
      jsondecode(local.launch_role_SimpleVPCAndLinux))
}

# TODO:
# is it possible to make a data lookup to see which product launch roles are missing?
# is it needed?

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

# A portfolio containing TrainingCostBudget and SimpleVPCAndLinux has already been shared
# with "Juniors", which means that we don't have to add local.MiscHelpers_launch_roles to
# the ServiceCatalogAccess, we can just hoo
module "ServiceCatalogAccessMiscHelpers" {
    source           = "./service_catalog_access_stackset"
    portfolio_name   = module.MiscHelpers.name
#    launch_roles     = local.MiscHelpers_launch_roles
    launch_roles     = local.MiscHelpers_no_new_launch_roles
    create_access    = true
    portfolio_ou_ids = module.MiscHelpers.ou_ids
    region           = local.region
    providers = {
      aws.shared = aws.shared
      aws.master = aws.master
    }
}