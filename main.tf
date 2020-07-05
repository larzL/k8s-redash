# Built for use with terragrunt
provider "aws" {
  region                      = "${var.aws_region}"
  profile                     = "${var.aws_profile}"
  skip_credentials_validation = true

  assume_role {
    role_arn     = "${var.aws_assume_role_arn}"
    session_name = "${var.aws_account_name}"
  }
}

terraform {
  backend "s3" {}
}

resource "random_string" "auth_token" {
  length  = 32
  special = false
}

# Redis
module "redash_redis" {
  source = "git::https://github.com/cloudposse/terraform-aws-elasticache-redis.git?ref=f44e9fab854c723e583bc79e54ddda560c9d2eae"

  namespace  = "${var.project}"
  stage      = "${var.environment}"
  auth_token = "${random_string.auth_token.result}"
  name       = "${var.redis_name}"
  label_id   = "${var.label_id}"

  security_groups = []

  vpc_id                       = ""
  subnets                      = []
  maintenance_window           = "${var.redis_maintenance_window}"
  cluster_size                 = "${var.redis_num_nodes}"
  instance_type                = "${var.redis_node_type}"
  engine_version               = "${var.redis_engine_version}"
  apply_immediately            = "${var.redis_apply_immediately}"
  replication_group_id         = "redis-${var.redis_name}"
  availability_zones           = ["${var.azs}"]
  family                       = "${var.redis_family}"
  automatic_failover           = "${var.redis_automatic_failover}"
  snapshot_window              = "${var.redis_snapshot_window}"
  snapshot_retention_limit     = "${var.redis_snapshot_retention_limit}"
  snapshot_arns                = "${var.redis_snapshot_arns}"
  snapshot_name                = "${var.redis_snapshot_name}"
  alarm_cpu_threshold_percent  = "${var.redis_alarm_cpu_threshold_percent}"
  alarm_memory_threshold_bytes = "${var.redis_alarm_memory_threshold_bytes}"
  at_rest_encryption_enabled   = "${var.redis_at_rest_encryption_enabled}"
  transit_encryption_enabled   = "${var.redis_transit_encryption_enabled}"
  zone_id                      = ""
}

# RDS
module "redash_rds" {
  source                    = "git::git@github.com:terraform-aws-modules/terraform-aws-rds-aurora.git?ref=c44cfe122fce5f5aa2471367e86acae392036d25"

  aws_profile               = "${var.aws_profile}"
  aws_region                = "${var.aws_region}"
  aws_account_name          = "${var.aws_account_name}"
  aws_assume_role_arn       = "${var.aws_assume_role_arn}"
  aws_mgmt_profile          = "${var.aws_mgmt_profile}"
  aws_mgmt_role_arn         = "${var.aws_mgmt_role_arn}"
  aws_mgmt_region           = "${var.aws_mgmt_region}"
  terragrunt_mgmt_s3_bucket = "${var.terragrunt_mgmt_s3_bucket}"

  owner         = "${var.owner}"
  project       = "${var.project}"
  environment   = "${var.environment}"
  securitylevel = "${var.securitylevel}"

  name = "${var.db_name}"

  allowed_security_groups = []

  dns_zone_id          = ""
  dns_name             = "rds-${var.db_name}"
  db_family            = "${var.db_family}"
  db_engine            = "${var.db_engine}"
  db_engine_version    = "${var.db_engine_version}"
  db_instance_type     = "${var.db_instance_type}"
  db_replica_count     = "${var.db_replica_count}"
  db_replica_count_max = "${var.db_replica_count_max}"
  db_username          = "${var.db_username}"
  db_password          = "${var.db_password}"
  autoscaling_enable   = "${var.db_autoscaling_enable}"
  monitoring_interval  = "${var.db_monitoring_interval}"
  apply_immediately    = "${var.db_apply_immediately}"
  skip_final_snapshot  = "${var.db_skip_final_snapshot}"
  storage_encrypted    = "${var.db_storage_encrypted}"
}

resource "kubernetes_service" "redash" {
  metadata {
    name      = "redash"
    namespace = "default"

    labels = {
      app = "redash"
    }
  }

  spec {
    port {
      name        = "http"
      protocol    = "TCP"
      port        = 80
      target_port = "http"
    }

    selector = {
      app = "redash"
    }

    type             = "NodePort"
    session_affinity = "None"
  }
}

resource "random_string" "redash_cookie_secret" {
  length  = 32
  special = false
}

resource "kubernetes_deployment" "redash" {
  metadata {
    name      = "redash"
    namespace = "default"

    labels = {
      app = "redash"
    }
  }

  spec {
    replicas = "${var.redash_replicas}"

    selector {
      match_labels = {
        app = "redash"
      }
    }

    template {
      metadata {
        labels = {
          app = "redash"
        }
      }

      spec {
        container {
          name  = "redash"
          image = "${var.redash_imata}"
          args  = ["server"]

          port {
            name           = "http"
            container_port = 5000
            protocol       = "TCP"
          }

          env {
            name  = "REDASH_LOG_LEVEL"
            value = "INFO"
          }

          env {
            name  = "REDASH_WEB_WORKERS"
            value = "${var.web_workers_count}"
          }

          env {
            name  = "REDASH_REDIS_URL"
            value = ""
          }

          env {
            name  = "POSTGRES_PASSWORD"
            value = "${module.redash_rds.cluster_master_password}"
          }

          env {
            name  = "REDASH_COOKIE_SECRET"
            value = "${random_string.redash_cookie_secret.result}"
          }

          env {
            name  = "REDASH_DATABASE_URL"
            value = ""
          }

          env {
            name  = "REDASH_DATE_FORMAT"
            value = "YYYY-MM-DD"
          }

          image_pull_policy = "IfNotPresent"

          resources {
            limits {
              cpu    = "${var.web_cpu_limits}"
              memory = "${var.web_memory_limits}"
            }

            requests {
              cpu    = "${var.web_cpu_requests}"
              memory = "${var.web_memory_requests}"
            }
          }
        }
      }
    }

    strategy {
      type = "RollingUpdate"
    }
  }
}
