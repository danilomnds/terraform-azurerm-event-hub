# Module - Azure Event Hub
[![COE](https://img.shields.io/badge/Created%20By-CCoE-blue)]()
[![HCL](https://img.shields.io/badge/language-HCL-blueviolet)](https://www.terraform.io/)
[![Azure](https://img.shields.io/badge/provider-Azure-blue)](https://registry.terraform.io/providers/hashicorp/azurerm/latest)

Module developed to standardize the EventHub namespace and Hub creation.

## Compatibility Matrix

| Module Version | Terraform Version | AzureRM Version |
|----------------|-------------------| --------------- |
| v1.0.0         | v1.5.2            | 3.63.0          |

## Specifying a version

To avoid that your code get updates automatically, is mandatory to set the version using the `source` option. 
By defining the `?ref=***` in the the URL, you can define the version of the module.

Note: The `?ref=***` refers a tag on the git module repo.

## Use case

```hcl
module "<evhns-name>" {
  source = "git::https://github.com/danilomnds/terraform-azurerm-event-hub?ref=v1.0.0"
  name = "<evhns-name>"
  location = "<location>"
  resource_group_name  = "<resource-group-name>"
  sku = "<Basic/Standard/Premium>"  
  capacity = <1>
  tags = {
    "key1" = "value1"
    "key2" = "value2"    
  }
  # optional (creation of the eventhub)
  hubs_parameters = {
    <evh-env-system> = {
      name = <evh-env-system>
      partition_count = <1>
      message_retention = <1>
    }, 
    <evh-env-system> = {
      name = <evh-env-system>
      partition_count = <1>
      message_retention = <1>
    }    
  }
  azure_ad_groups = ["group id 1"]
}
output "evhns_name" {
  value = module.<evhns-name>.name
}
output "evhns_id" {
  value = module.<evhns-name>.id
}

output "evh_hubs" {
  value = module.<evhns-name>.hubs
}
```

## Input variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | eventhub namespace name | `string` | n/a | `Yes` |
| location | azure region | `string` | n/a | `Yes` |
| resource_group_name | resource group where the ACR will be placed | `string` | n/a | `Yes` |
| sku | sku | `string` | `Standard` | `Yes` |
| capacity | specifies the capacity / throughput units for a standard sku namespace | `number` | `1` | No |
| auto_inflate_enabled | is auto inflate enabled for the eventhub namespace? | `bool` | `false` | No |
| dedicated_cluster_id | specifies the id of the eventhub dedicated cluster where this namespace should created | `string` | n/a | No |
| identity | block as defined below | `object()` | n/a | No |
| maximum_throughput_units | specifies the maximum number of throughput units when auto inflate is enabled | `number` | `1` | No |
| zone_redundant | specifies if the eventhub namespace should be zone redundant  | `bool` | `false` | No |
| tags | tags for the resource | `map(string)` | `{}` | No |
| network_rulesets | block as defined below | `object()` | n/a | No |
| local_authentication_enabled | is sas authentication enabled for the eventhub namespace | `bool` | `true` | No |
| public_network_access_enabled | is public network access enabled for the eventhub namespace | `bool` | `false` | No |
| minimum_tls_version | the minimum supported tls version for this eventhub namespace | `bool` | `false` | No |
| hubs_parameters | hubs specifications | `object` | `{}` | No |
| azure_ad_groups | list of azure AD groups that will be granted the Reader role  | `list` | `[]` | No |
| eventhub_custom_role | Allows the Event Hub owner to get write and delete the keys on eventhub only | `bool` | `true` | No |
| data_receiver | allows receive access to azure event hubs resources | `bool` | `true` | No |
| data_sender | allows send access to azure event hubs resources | `bool` | `true` | No |

## Object variables for blocks

| Variable Name (Block) | Parameter | Description | Type | Default | Required |
|-----------------------|-----------|-------------|------|---------|:--------:|
| identity | type | specifies the type of managed service identity that should be configured on this event hub namespace | `string` | `null` | No |
| identity | identity_ids | specifies a list of user assigned managed identity ids to be assigned to this eventhub namespace | `list(string)` | `null` | No |
| network_rulesets | default_action | the default action to take when a rule is not matched | `optional(string)` | `Allow` | `Yes` |
| network_rulesets | public_network_access_enabled | is public network access enabled for the eventhub namespace | `optional(bool)` | `false` | No |
| network_rulesets | trusted_service_access_enabled | whether trusted microsoft services are allowed to bypass firewall | `bool` | `true` | No |
| network_rulesets | virtual_network_rule (block) subnet_id | the id of the subnet to match on | `optional(list(object(string)))` | `{}` | `Yes` |
| network_rulesets | virtual_network_rule ignore_missing_virtual_network_service_endpoint | are missing virtual network service endpoints ignored | `optional(list(object(string)))` | `{}` | No |
| network_rulesets | ip_rule (block) ip_mask | the IP mask to match on | `optional(list(object(string)))` | `{}` | `Yes` |
| hubs_parameters | name | specifies the name of the eventhub resource | `map(object(string))` | n/a | `Yes` |
| hubs_parameters | partition_count | specifies the current number of shards on the event hub | `map(object(number))` | n/a | `Yes` |
| hubs_parameters | message_retention | specifies the number of days to retain the events for this event hub | `map(object(optional(number)))` | `1` | No |
| hubs_parameters | capture_description (block) enabled | specifies if the capture description is enabled | `map(object(optional(object(bool)))))` | `true` | `Yes` |
| hubs_parameters | capture_description (block) enconding | specifies the encoding used for the capture description | `map(object(optional(object(string)))))` | `true` | `Yes` |
| hubs_parameters | capture_description (block) interval_in_seconds | specifies the time interval in seconds at which the capture will happen | `map(object(optional(object(number)))))` | n/a | No |
| hubs_parameters | capture_description (block) size_limit_in_bytes | specifies the amount of data built up in your eventhub before a capture operation occurs | `map(object(optional(object(number)))))` | n/a | No |
| hubs_parameters | capture_description (block) skip_empty_archives | specifies the amount of data built up in your eventhub before a capture operation occurs | `map(object(optional(object(bool)))))` | n/a | No |
| hubs_parameters | capture_description (block) destination (subblock) name | the name of the destination where the capture should take place | `map(object(optional(object(object(optional(string))))))` | n/a | `Yes` |
| hubs_parameters | capture_description (block) destination (subblock) archive_name_format | the blob naming convention for archiving | `map(object(optional(object(object(optional(string))))))` | n/a | `Yes` |
| hubs_parameters | capture_description (block) destination (subblock) blob_container_name | the name of the container within the blob storage account where messages should be archived | `map(object(optional(object(object(optional(string))))))` | n/a | `Yes` |
| hubs_parameters | capture_description (block) destination (subblock) storage_account_id | the id of the blob storage account where messages should be archived | `map(object(optional(object(object(optional(string))))))` | n/a | `Yes` |
| hubs_parameters | status | specifies the status of the event hub resource | `map(object(optional(string)))` | n/a | No |



## Output variables

| Name | Description |
|------|-------------|
| name | eventhub namespace name |
| id | eventhub namespace id |
| hubs | eventhub's ids |

## Documentation

Terraform Event Hub Namespace: <br>
[https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_namespace](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub_namespace)<br>

Terraform Event Hub: <br>
[https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/eventhub)<br>
