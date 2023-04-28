# usage

    module "SomeProductName" {
        source        = "./product_with_versions"
        product_name  = "SomeProductName"
        product_owner = "Terraform"
        product_description   = "SomeProductName overall product description"
        versions = [
            {
                name         = "v1.0"
                description  = "SomeProductName version v1.0 description"
                template     = "SomeProductName_v1.0.yaml"
                bucket       = aws_s3_bucket.products
            },
            {
                name         = "v1.1"
                description  = "SomeProductName version v1.1 description"
                template     = "SomeProductName_v1.1.yaml"
                bucket       = aws_s3_bucket.products
            }
        ]

        launch_role_policy_document = jsonencode({
            Version = "2012-10-17"
            Statement = [
                {
                    Action = [
                        "service:*",
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

After construction of a module instance, the following information is available

    module.SomeProductName.product_id
    module.SomeProductName.launch_role_policy_document

This information is used in Service Catalog Portfolio definitions (A product can be used in several portfolios if needed). 

The Launch Role Policy Document is defined in connection with the Product, because the product producer has the best ability to define a correct policy. The policy is used to make constraints in Service Catalog and to make named Launch Roles in the accounts under the ou's the portfolio ends up being shared with.
