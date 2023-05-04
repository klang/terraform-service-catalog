terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.7.0"
      configuration_aliases = [ aws.shared, aws.master ]
    }
  }
}


resource aws_cloudformation_stack_set "ServiceCatalogAccessStackSet" {
    provider = aws.shared
    #administration_role_arn = aws_iam_role.AWSCloudFormationStackSetAdministrationRole.arn
  
    name = "ServiceCatalogAccessStackSet-${var.portfolio_name}"
    #name = "ServiceCatalogAccessStackSet"
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
        Resources = var.launch_roles
        }
    )
}

resource "aws_cloudformation_stack_set_instance" "ou" {
    #count = 0 # uncomment to include .. will take 20 minutes, most likely
    provider = aws.shared
    call_as = "DELEGATED_ADMIN"
    deployment_targets {
        organizational_unit_ids = var.portfolio_ou_ids
    }
    operation_preferences {
        max_concurrent_percentage = 100
        failure_tolerance_percentage = 0
    }
    region         = var.region
    stack_set_name = aws_cloudformation_stack_set.ServiceCatalogAccessStackSet.name
}