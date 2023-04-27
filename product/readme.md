
# usage

    module "product" {
        source        = "./product"
        description = "test"
        version_name = "v1.0"
        product_name = "testing"
        template_url = "https://940740948575-service-catalog-products.s3.eu-west-1.amazonaws.com/AccountSpecificTrustRole.yaml"
        providers = {
            aws.shared = aws.shared
            aws.master = aws.master
        }
    }
