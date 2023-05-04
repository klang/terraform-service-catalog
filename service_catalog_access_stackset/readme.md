# usage

    module "SomeProductName" {
        source           = "./service_catalog_access_stackset"
        portfolio_name   = module.portfolio.name
        launch_roles     = local.launch_roles
        portfolio_ou_ids = module.portfolio.ou_ids
        region           = local.region
    }
    .. tbd 