
# CloudFormation Stack to create a Service Catalog Launch Role (for each products) in every account in an OU
# we have the Stack that can create the launch roles for each product
# we need the principalNames from https://github.com/dashsoftaps/cdk-service-catalog-typescript/blob/master/lib/service-catalog-access-stackset/service-catalog-access-stack.ts


locals {
    launch_role_TrainingCostBudget = templatefile(
            "${path.module}/templates/service-catalog-launch-role.tftpl", 
            {
              ProductName  = "TrainingCostBudget",
              PolicyDocument = module.TrainingCostBudget.launch_role_policy_document,
            }
          )
    launch_role_TrustRole = templatefile(
            "${path.module}/templates/service-catalog-launch-role.tftpl", 
            {
              ProductName  = "TrustRole",
              PolicyDocument = module.TrustRole.launch_role_policy_document,
            }
          )
    launch_role_AccountSpecificTrustRole = templatefile(
            "${path.module}/templates/service-catalog-launch-role.tftpl", 
            {
              ProductName  = "AccountSpecificTrustRole",
              PolicyDocument = module.AccountSpecificTrustRole.launch_role_policy_document,
            }
          )
    launch_role_SimpleVPCAndLinux = templatefile(
            "${path.module}/templates/service-catalog-launch-role.tftpl", 
            {
              ProductName  = "SimpleVPCAndLinux",
              PolicyDocument = module.SimpleVPCAndLinux.launch_role_policy_document,
            }
          )
    launch_roles = merge(
      jsondecode(local.launch_role_TrainingCostBudget),
      jsondecode(local.launch_role_TrustRole),
      jsondecode(local.launch_role_AccountSpecificTrustRole),
      jsondecode(local.launch_role_SimpleVPCAndLinux))
}

/* 
output "launch_roles_launch_role_SimpleVPCAndLinux" {
  value = jsondecode(local.launch_role_SimpleVPCAndLinux)
}
output "launch_role_TrainingCostBudget" {
  value = jsondecode(local.launch_role_TrainingCostBudget)
}
output "launch_roles" {
  value = local.launch_roles  
} */

# this works, but has to be part of the StackSet below
/* resource "aws_cloudformation_stack" "ServiceCatalogAccess" {
  name = "ServiceCatalogAccess"
  capabilities = ["CAPABILITY_NAMED_IAM"]
  template_body = jsonencode({
      AWSTemplateFormatVersion = "2010-09-09",
      Description = "Service Catalog Service Permissions",
      Resources = local.launch_roles
    }
  )
} */

# Error: creating CloudFormation StackSet (ServiceCatalogAccessStackSet-port-kt6pnzxfgzaik): 
# ValidationError: You must be the management account or delegated admin account of an organization before operating a SERVICE_MANAGED stack set
/* data "aws_iam_policy_document" "AWSCloudFormationStackSetAdministrationRole_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      identifiers = ["cloudformation.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "AWSCloudFormationStackSetAdministrationRole" {
  assume_role_policy = data.aws_iam_policy_document.AWSCloudFormationStackSetAdministrationRole_assume_role_policy.json
  name               = "AWSCloudFormationStackSetAdministrationRole"
} */

data "aws_organizations_delegated_administrators" "on_shared" {
    provider = aws.shared
    service_principal = "servicecatalog.amazonaws.com"
}
output "delegated_administrator_service_catalog" {
    value = data.aws_organizations_delegated_administrators.on_shared
}

data "aws_organizations_delegated_administrators" "for_stacksets" {
    provider = aws.shared
    service_principal = "member.org.stacksets.cloudformation.amazonaws.com"
    depends_on = [ aws_organizations_delegated_administrator.member_for_stacksets ]
}

output "delegated_administrator_stack_sets" {
    value = data.aws_organizations_delegated_administrators.for_stacksets
}

resource "aws_organizations_delegated_administrator" "member_for_stacksets" {
    provider = aws.master
    account_id        = local.account_id
    service_principal = "member.org.stacksets.cloudformation.amazonaws.com"
}


/* resource "aws_organizations_delegated_administrator" "management_for_stacksets" {
    provider = aws.master
    account_id        = local.account_id
    service_principal = "stacksets.cloudformation.amazonaws.com"
} */



#  awsume controltower
#  aws organizations list-delegated-services-for-account --account-id 940740948575

# TODO: make a module for this .. 

resource aws_cloudformation_stack_set "ServiceCatalogAccessStackSet" {
    provider = aws.shared
    #administration_role_arn = aws_iam_role.AWSCloudFormationStackSetAdministrationRole.arn
  
    #name = "ServiceCatalogAccessStackSet-${module.portfolio.portfolio.id}"
    name = "ServiceCatalogAccessStackSet"
    permission_model = "SERVICE_MANAGED"
    call_as = "DELEGATED_ADMIN"
    auto_deployment {
      enabled = true
      retain_stacks_on_account_removal = false
    }
    operation_preferences {
        max_concurrent_percentage = 100
        failure_tolerance_percentage = 0
    }
    
    capabilities = ["CAPABILITY_NAMED_IAM"]

    # local.launch_roles contain the launch roles for EVERY POSSIBLE PRODUCT on the account
    # iam roles are global, so they can't be applied multiple times unless we use different names
    # different names for the same product launch role is considered outide the scope of this project
    template_body = jsonencode({
        AWSTemplateFormatVersion = "2010-09-09",
        Description = "Service Catalog Service Permissions",
        Resources = local.launch_roles
        }
    )
}

resource "aws_cloudformation_stack_set_instance" "ou" {
    count = 0 # uncomment to include .. will take 20 minutes, most likely
    provider = aws.shared
    call_as = "DELEGATED_ADMIN"
    deployment_targets {
        organizational_unit_ids = module.portfolio.ou_ids
    }
    operation_preferences {
        max_concurrent_percentage = 100
        failure_tolerance_percentage = 0
    }
    region         = local.region
    stack_set_name = aws_cloudformation_stack_set.ServiceCatalogAccessStackSet.name
}