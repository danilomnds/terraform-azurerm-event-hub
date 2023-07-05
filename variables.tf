variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "sku" {
  type    = string
  default = "Standard"
}

variable "capacity" {
  type    = number
  default = 1
}

variable "auto_inflate_enabled" {
  type    = bool
  default = false
}

variable "dedicated_cluster_id" {
  type    = string
  default = null
}

variable "identity" {
  description = "Specifies the type of Managed Service Identity that should be configured on this Container Registry"
  type = object({
    type         = string
    identity_ids = optional(list(string))
  })
  default = null
}

variable "maximum_throughput_units" {
  type    = number
  default = null
}

variable "zone_redundant" {
  type    = bool
  default = false
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "network_rulesets" { # change this to match actual objects
  description = "Manage network rules for Azure Container Registries"
  type = object({
    default_action                 = optional(string)
    public_network_access_enabled  = optional(bool)
    trusted_service_access_enabled = optional(bool)
    virtual_network_rule = optional(list(object({ subnet_id = string
    ignore_missing_virtual_network_service_endpoint = bool })))
    ip_rule = optional(list(object({ ip_mask = string })))
  })
  default = null
}

variable "local_authentication_enabled" {
  type    = bool
  default = true
}

variable "public_network_access_enabled" {
  type    = bool
  default = false
}

variable "minimum_tls_version" {
  type    = number
  default = 1.2
}

variable "hubs_parameters" {
  description = "Map of Event Hub parameters objects (key is hub shortname)."
  type = map(object({
    name       = string
    partition_count   = number
    message_retention = optional(number, 7)
    capture_description = optional(object({
      enabled             = optional(bool, true)
      encoding            = string
      interval_in_seconds = optional(number)
      size_limit_in_bytes = optional(number)
      skip_empty_archives = optional(bool)
      destination = object({
        name                = optional(string, "EventHubArchive.AzureBlockBlob")
        archive_name_format = optional(string)
        blob_container_name = string
        storage_account_id  = string
      })
    }))
    status = optional(string)
  }))
  default = {}
}

variable "azure_ad_groups" {
  type = list(string)
  default = []
}

variable "eventhub_custom_role" {
  description = "Allows the Event Hub owner to get write and delete the keys on eventhub only. "
  type        = bool
  default     = true
}

variable "data_receiver" {
  description = "Allows receive access to Azure Event Hubs resources."
  type        = bool
  default     = true
}

variable "data_sender" {
  description = "Allows send access to Azure Event Hubs resources."
  type        = bool
  default     = true
}