# provider values
variable "terragrunt_mgmt_s3_bucket" {}

variable "aws_mgmt_region" {}

variable "aws_mgmt_profile" {}

variable "aws_mgmt_role_arn" {}

variable "aws_account_name" {}

variable "aws_profile" {}

variable "aws_region" {}

variable "aws_assume_role_arn" {}

variable "azs" {
  default = []
}

# labels and tags
variable "environment" {}

variable "owner" {}

variable "project" {}

variable "securitylevel" {}

variable "service" {
  default = ""
}

variable "role" {
  default = "redash"
}

variable "cluster" {
  default = ""
}

variable "redash_imata" {
  default = "redash/redash:6.0.0.b8537"
}

variable "redash_replicas" {
  default = "1"
}

variable "web_workers_count" {
  default = "3 -t600"
}


variable "web_cpu_limits" {
  default = "200m"
}

variable "web_cpu_requests" {
  default = "100m"
}

variable "web_memory_limits" {
  default = "1Gi"
}

variable "web_memory_requests" {
  default = "1Gi"
}

# redis module specific
variable "redis_name" {
  default = "redash"
}

variable "label_id" {
  default = "true"
}

variable "redis_maintenance_window" {
  default = "wed:03:00-wed:04:00"
}

variable "redis_automatic_failover" {
  default = "false"
}

variable "redis_apply_immediately" {
  default = "true"
}

variable "redis_node_type" {
  default = "cache.t2.medium"
}

variable "redis_num_nodes" {
  default = "1"
}

variable "redis_engine_version" {
  default = "5.0.6"
}

variable "redis_family" {
  default = "redis5.0"
}

variable "redis_snapshot_window" {
  default = "07:00-08:00"
}

variable "redis_snapshot_retention_limit" {
  default = "1"
}

variable "redis_snapshot_arns" {
  default = []
}

variable "redis_snapshot_name" {
  default = ""
}

variable "redis_alarm_cpu_threshold_percent" {
  default = "75"
}

variable "redis_alarm_memory_threshold_bytes" {
  default = "10000000"
}

variable "redis_transit_encryption_enabled" {
  default = "false"
}

variable "redis_at_rest_encryption_enabled" {
  default = "true"
}

# aurora module specific
variable "restore_from_snapshot" {
  default = false
}

variable "snapshot_db_cluster_snapshot_identifier" {
  default = ""
}

variable "db_dns_create" {
  default = true
}

variable "db_name" {
  default = "redash"
}

variable "db_username" {
  default = ""
}

variable "db_password" {
  default = ""
}

variable "db_engine" {
  default = "aurora-postgresql"
}

variable "db_engine_version" {
  default = "9.6.16"
}

variable "db_family" {
  default = "aurora-postgresql9.6"
}

variable "db_instance_type" {
  default = "db.r5.large"
}

variable "db_replica_count" {
  default = "1"
}

variable "db_replica_count_max" {
  default = "5"
}

variable "db_autoscaling_enable" {
  default = "true"
}

variable "db_monitoring_interval" {
  description = "The interval (seconds) between points when Enhanced Monitoring metrics are collected"
  default     = "60"
}

variable "db_apply_immediately" {
  description = "Determines whether or not any DB modifications are applied immediately, or during the maintenance window"
  default     = "true"
}

variable "db_skip_final_snapshot" {
  description = "Should we skip creating a final snapshot on cluster destroy"
  default     = "true"
}

variable "db_storage_encrypted" {
  default = "false"
}
