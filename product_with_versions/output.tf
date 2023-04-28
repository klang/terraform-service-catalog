output "product_id" {
  value = aws_servicecatalog_product.this.id
}

output launch_role_policy_document {
    value = var.launch_role_policy_document
}