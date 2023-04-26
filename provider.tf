provider "aws" {
  assume_role {
    external_id = "terraform"
    session_name = "terraform"
    role_arn = "arn:aws:iam::${local.account_id}:role/terraform"
  }
  region = "${local.region}"
}

data "aws_caller_identity" "current" {
}

provider "aws" {
  alias = "shared"
  assume_role {
    external_id = "terraform"
    session_name = "terraform"
    role_arn = "arn:aws:iam::${local.account_id}:role/terraform"
  }
  region = "${local.region}"
}

provider "aws" {
  alias = "master"
  assume_role {
    external_id = "terraform"
    session_name = "terraform"
    role_arn = "arn:aws:iam::${local.master_account_id}:role/terraform"
  }
  region = "eu-west-1"
}
