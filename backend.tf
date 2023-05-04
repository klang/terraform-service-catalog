terraform {
  required_version = "<=1.3.9"
  /*
  awsume shared-services
  aws s3 mb s3://940740948575-service-catalog-terraform-state
  awsume iam
  terraform init
  # answer "yes" to change the backend
  */

  backend "s3" {
    bucket = "940740948575-service-catalog-terraform-state"
    key = "terraform.tfstate"
    region = "eu-west-1"
    external_id = "terraform"
    session_name = "terraform"
    role_arn = "arn:aws:iam::940740948575:role/terraform"
  }
}