variable product_name  {}
variable product_owner {default = "Shared Services"}
#variable product_type {default = "CLOUD_FORMATION_TEMPLATE"}
variable disable_template_validation {default = true}

variable description {  }
variable product_description { default = "" }
variable version_description { default = "" }
variable version_name { }
variable template_url { }
variable tag_creator {default = "Terraform"}

locals {
    product_description = "${var.product_description}" != "" ? var.product_description : var.description 
    version_description = "${var.version_description}" != "" ? var.version_description : var.description 
}