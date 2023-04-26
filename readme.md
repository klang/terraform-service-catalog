
## init

    tfswitch 1.3.9
    terraform init
    awsume iam

## workspaces

It is possible to have a full workspace specific set of accounts if needed. Adjust [variables.tf](./variables.tf) for this.

    terraform workspace new training
    terraform workspace new <customer>

## add the AWS config

Add to `~/.aws/config`

    [profile <customer>]
    role_arn = arn:aws:iam::<accountid>:role/cloudpartners-iam
    source_profile = iam

## add Terraform iam role

The settings in `variables.tf` set up the providers needed in `provider.tf`, but require a `terraform` role on the target accounts.

The template is `cross-account-access-terraform.yaml` and has to be added 

    awsume training
    aws cloudformation create-stack --stack-name CrossAccountAccessTerraform --capabilities CAPABILITY_NAMED_IAM --template-body file://cross-account-access-terraform.yaml
    awsume iam

    awsume <customer>
    aws cloudformation create-stack --stack-name CrossAccountAccessTerraform --capabilities CAPABILITY_NAMED_IAM --template-body file://cross-account-access-terraform.yaml
    aws s3 mb s3://<accountid>-<customer>-terraform-state
    awsume iam

    awsume controltower
    aws cloudformation create-stack --stack-name CrossAccountAccessTerraform --capabilities CAPABILITY_NAMED_IAM --template-body file://cross-account-access-terraform.yaml

    awsume shared-services
    aws cloudformation create-stack --stack-name CrossAccountAccessTerraform --capabilities CAPABILITY_NAMED_IAM --template-body file://cross-account-access-terraform.yaml

Note that we have prepared a bucket for the terraform state. This bucket is referred in `backend.tf` too.

