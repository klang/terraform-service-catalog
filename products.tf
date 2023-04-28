resource "aws_s3_bucket" "products" {
  bucket = "${local.account_id}-service-catalog-products"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "products" {
  bucket = aws_s3_bucket.products.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

resource "aws_s3_object" "product" {
  for_each = fileset("products/", "*.yaml")
  bucket = aws_s3_bucket.products.id
  key = "${each.value}"
  source = "products/${each.value}"
  etag = filemd5("products/${each.value}")
}
