/*
data "aws_availability_zones" "available" {}
output "availability_zones" {
  value = data.aws_availability_zones.available
}
*/

module "portfolio" {
  source                  = "./portfolio"
  portfolio_name          = "Nice Helpers Terraform"
  portfolio_description   = "Example Portfolio provided and managed by Terraform"
  portfolio_provider_name = "Terraform"
  #training (pre-existing products)
  #products = ["prod-ytfjfndekv6lk", "prod-35wvktpt3n4ei"]
  #shared-services (pre-existing products)
  products = ["prod-6ad34fypnowfy", "prod-54fwbgl57phw4"]
  ou_names = ["Custom", "Training", "Juniors"]
  providers = {
    aws.shared = aws.shared
    aws.master = aws.master
   }
}

output "portfolio" {
  value = module.portfolio.portfolio 
}
