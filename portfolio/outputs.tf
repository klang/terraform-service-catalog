output "portfolio" {
  value = aws_servicecatalog_portfolio.portfolio
}

output "ou_names" {
    value = var.ou_names
}

output "ou_arns" {
    value = local.ou_arns
}

output "ou_ids" {
    value = local.ou_ids
}