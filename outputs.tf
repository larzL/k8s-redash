output "rds_master_username" {
  description = "The master username"
  value       = "${module.redash_rds.cluster_master_username}"
}

output "rds_master_password" {
  sensitive   = true
  description = "The master password"
  value       = "${module.redash_rds.cluster_master_password}"
}
