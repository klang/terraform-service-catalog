terraform {
  required_version = "<=1.3.9"
  /*
  awsume training
  aws s3 mb s3://<accountid>-<project>-terraform-state
  awsume iam
  terraform init
  # answer "yes" to change the backend
  */
  /*
  backend "s3" {
    bucket = "s3://<accountid>-<project>-terraform-state"
    key = "terraform.tfstate"
    region = "eu-west-1"
    external_id = "terraform"
    session_name = "terraform"
    role_arn = "arn:aws:iam::<accountid>:role/terraform"
  }
  */
}