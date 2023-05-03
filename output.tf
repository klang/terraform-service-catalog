output "TrainingCostBudget" {
  value = module.TrainingCostBudget.product_id
}
output "TrainingCostBudgetLaunchRolePolicyDocument" {
  value = module.TrainingCostBudget.launch_role_policy_document
}
output "TrustRole" {
  value = module.TrustRole.product_id
}
output "TrustRoleLaunchRolePolicyDocument"{
  value = module.TrustRole.launch_role_policy_document
}
output "SimpleVPCAndLinux" {
  value = module.SimpleVPCAndLinux.product_id
}
output "SimpleVPCAndLinuxLaunchRolePolicyDocument" {
  value = module.SimpleVPCAndLinux.launch_role_policy_document
}
output "AccountSpecificTrustRole" {
  value = module.AccountSpecificTrustRole.product_id
}
output "AccountSpecificTrustRoleLaunchRolePolicyDocument" {
  value = module.AccountSpecificTrustRole.launch_role_policy_document
}
output "ou_names" {
    value = module.portfolio.ou_names
}
output "ou_arns" {
    value = module.portfolio.ou_arns
}
output "ou_ids" {
    value = module.portfolio.ou_ids
}
