# lookup Roles made by the stackset

    awsume training
    aws iam list-roles --query 'Roles[?PolicyName!=`null`].RoleName|[?starts_with(RoleName,`ServiceCatalogLaunchRole`)]'

    aws iam list-roles | grep  ServiceCatalogLaunchRole