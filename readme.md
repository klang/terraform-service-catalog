
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


# Warning

Some of the elements we are using in this project do no play nice with parallel execution currently:

    │ Error: creating Service Catalog Portfolio Share: InvalidStateException: Cannot process more than one portfolio share action at the same time. Try again later.
    │
    │   with module.portfolio.aws_servicecatalog_portfolio_share.organizational_units[0],
    │   on portfolio/main.tf line 40, in resource "aws_servicecatalog_portfolio_share" "organizational_units":
    │   40: resource "aws_servicecatalog_portfolio_share" "organizational_units" {

This can be fixed by explicitly setting parallelism to 1, as indicated below.

# set delegated administrator

[SharedService Service Catalog delegated master](https://cloudpartners.atlassian.net/wiki/spaces/DEV/pages/2271084578/SharedService+Service+Catalog+delegated+master)

## step 1

    awsume controltower

    aws organizations enable-aws-service-access --service-principal servicecatalog.amazonaws.com
    aws organizations enable-aws-service-access --service-principal member.org.stacksets.cloudformation.amazonaws.com
    aws organizations list-aws-service-access-for-organization

## step 2

    awsume controltower
    aws organizations list-delegated-administrators
    # aws organizations list-accounts
    delegated=$(aws organizations list-accounts | jq -r '.Accounts[] | select(.Name=="SharedServices") | .Id')
    aws organizations register-delegated-administrator --account-id $delegated --service-principal servicecatalog.amazonaws.com
    aws organizations list-delegated-administrators

    aws organizations list-delegated-services-for-account --account-id 940740948575

    https://docs.aws.amazon.com/cli/latest/reference/organizations/enable-aws-service-access.html


    awsume controltower
    aws organizations enable-aws-service-access --service-principal stacksets.cloudformation.amazonaws.com


### This has already been established above and isn't needed in the code

    /*
    resource "aws_organizations_delegated_administrator" "on_master" {
        provider = aws.master
        account_id        = local.account_id
        service_principal = "servicecatalog.amazonaws.com"
    }
    */
    /* 

    terraform import aws_organizations_delegated_administrator.on_master 940740948575/servicecatalog.amazonaws.com
    terraform state rm aws_organizations_delegated_administrator.on_master
    */



## step 3

    awsume shared-services

    aws servicecatalog create-portfolio --display-name SharedServices --description 'Service Catalog shared portfolio' --provider-name "Base"
    export portfolio=$(aws servicecatalog list-portfolios | jq -r '.PortfolioDetails[] | select(.DisplayName=="SharedServices") | .Id')
    echo $portfolio

    awsume controltower
    aws ssm put-parameter --name '/org/sharedservices/servicecatalog/sharedportfolioid' --value $portfolio --description 'Service Catalog shared portfolio id' --type String --overwrite

    export oid=$(aws organizations describe-organization --query Organization.Id --output text)
    echo $oid

    awsume shared-services 
    aws servicecatalog create-portfolio-share --portfolio-id $portfolio  --organization-node Type=ORGANIZATION,Value=$oid


# terraform apply

    TF_CLI_ARGS_apply="-parallelism=1"
    terraform apply