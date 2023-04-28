variable product_name  {}
variable product_owner {default = "Shared Services"}
#variable product_type {default = "CLOUD_FORMATION_TEMPLATE"}
variable disable_template_validation {default = true}

variable product_description { default = null }
variable tag_creator {default = "Terraform"}

variable versions {
    type = list
    /* type = list({
        name = string
        vdescription = string
        template = string
        bucket = object}
        ) */
    }

variable launch_role_policy_document { default = null }