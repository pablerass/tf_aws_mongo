variable "module" {
  description = "Terraform module"

  default = "tf_aws_mongo"
}

variable "replica_set_count" {
  description = "Count of Replice Set instances per shard"
  default     = 2
}

variable "shards_count" {
  description = "Nomber of shards"
  default     = 1
}

variable "mongos_count" {
  description = "Count of Mongos instances"
  default     = 0
}

variable "mongos_instance_type" {
  description = "Instace type for Mongos instances"
  default     = ""
}

variable "config_count" {
  description = "Count of Config instances"
  default     = 0
}

variable "config_instance_type" {
  description = "Config type of Mongos instances"
  default     = ""
}

variable "tags" {
  description = "Resources tags"
  default     = {}
}

variable "instance_tags" {
  description = "Instance tags"
  default     = {}
}

variable "admin_cidrs" {
  description = "Adminitration CIDRs for remote access"
  default     = []
}

variable "admin_sg_ids" {
  description = "Adminitration Security Group ids for remote access"
  default     = []
}
