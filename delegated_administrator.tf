data "aws_organizations_delegated_administrators" "on_shared" {
    provider = aws.shared
    service_principal = "servicecatalog.amazonaws.com"
}
/* output "delegated_administrator_service_catalog" {
    value = data.aws_organizations_delegated_administrators.on_shared
} */

data "aws_organizations_delegated_administrators" "for_stacksets" {
    provider = aws.shared
    service_principal = "member.org.stacksets.cloudformation.amazonaws.com"
    depends_on = [ aws_organizations_delegated_administrator.member_for_stacksets ]
}

/* output "delegated_administrator_stack_sets" {
    value = data.aws_organizations_delegated_administrators.for_stacksets
} */

resource "aws_organizations_delegated_administrator" "member_for_stacksets" {
    provider = aws.master
    account_id        = local.account_id
    service_principal = "member.org.stacksets.cloudformation.amazonaws.com"
}


/* resource "aws_organizations_delegated_administrator" "management_for_stacksets" {
    provider = aws.master
    account_id        = local.account_id
    service_principal = "stacksets.cloudformation.amazonaws.com"
} */



#  awsume controltower
#  aws organizations list-delegated-services-for-account --account-id 940740948575