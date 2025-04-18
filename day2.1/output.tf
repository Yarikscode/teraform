output "boot_disk_id" {
  description = "The ID of the boot disk created for the instance."
  value       = yandex_compute_disk.boot_disk.id
}

output "instance_id" {
  description = "The ID of the Yandex Compute instance."
  value       = yandex_compute_instance.this.id
}

output "subnet_id" {
  description = "The ID of the VPC subnet used by the Yandex Compute instance."
  value       = yandex_vpc_subnet.private.id
  sensitive   = true
}

output "subnet_cidr" {
  description = "The ID of the VPC subnet used by the Yandex Compute instance."
  value       = local.subnet_cidr
}

output "access_key_value" {
  value       = yandex_iam_service_account_static_access_key.this.service_account_id
}

output "access_key_secret_value" {
  sensitive   = true
  value       = yandex_iam_service_account_static_access_key.this.secret_key
}

output "ydb_id" {
  description = "The ID of the Yandex Managed Service for YDB instance."
  value       = yandex_ydb_database_serverless.this.id
  sensitive   = true
}

output "service_account_id" {
  description = "The ID of the Yandex IAM service account."
  value       = yandex_iam_service_account.bucket.id
}

output "bucket_name" {
  description = "The name of the Yandex Object Storage bucket."
  value       = yandex_storage_bucket.this.bucket
}

output "instance_public_ip_address" {
  description = "The external IP address of the instance."
  value       = yandex_compute_instance.this.network_interface.0.nat_ip_address
} 
