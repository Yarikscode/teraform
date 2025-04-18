# Local values
locals {
  boot_disk_name      = var.boot_disk_name != null ? var.boot_disk_name : "${var.name_prefix}-boot-disk"
  linux_vm_name       = var.linux_vm_name != null ? var.linux_vm_name : "${var.name_prefix}-linux-vm"
  vpc_network_name    = var.vpc_network_name != null ? var.vpc_network_name : "${var.name_prefix}-private"
  ydb_serverless_name = var.ydb_serverless_name != null ? var.ydb_serverless_name : "${var.name_prefix}-ydb-serverless"
  bucket_sa_name      = var.bucket_sa_name != null ? var.bucket_sa_name : "${var.name_prefix}-bucket-sa"
  bucket_name         = var.bucket_name != null ? var.bucket_name : "${var.name_prefix}-terraform-bucket-${random_string.bucket_name.result}"
}

# Создание дисков и виртуальных машин
resource "yandex_compute_disk" "boot_disk" {
  for_each = var.zones

  name     = length(var.zones) > 1 ? "${local.boot_disk_name}-${substr(each.value, -1, 0)}" : local.boot_disk_name
  zone     = each.value
  image_id = var.image_id

  type = var.instance_resources.disk.disk_type
  size = var.instance_resources.disk.disk_size
}

resource "yandex_compute_instance" "this" {
  for_each = var.zones

  name                      = length(var.zones) > 1 ? "${local.linux_vm_name}-${substr(each.value, -1, 0)}" : local.linux_vm_name
  allow_stopping_for_update = true
  platform_id               = var.instance_resources.platform_id
  zone                      = each.value

  resources {
    cores  = var.instance_resources.cores
    memory = var.instance_resources.memory
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot_disk[each.value].id
  }

  network_interface {
    subnet_id      = yandex_vpc_subnet.private[each.value].id
    nat            = true
    nat_ip_address = yandex_vpc_address.this[each.value].external_ipv4_address[0].address
  }
  dynamic "secondary_disk" {
  for_each = try([yandex_compute_disk.secondary[each.value]], [])
  content {
    disk_id = secondary_disk.value.id
   }
  }

  metadata = {
    user-data = templatefile("cloud-init.yaml.tftpl", {
      ydb_connect_string = yandex_ydb_database_serverless.this.ydb_full_endpoint,
      bucket_domain_name = yandex_storage_bucket.this.bucket_domain_name
    })
  }
}

resource "time_sleep" "wait_120_seconds" {
  create_duration = "120s"

  depends_on = [yandex_compute_instance.this]
} 

resource "yandex_compute_snapshot" "initial" {
  for_each = yandex_compute_disk.boot_disk

  name           = "${each.value.name}-initial"
  source_disk_id = each.value.id

  depends_on = [time_sleep.wait_120_seconds]
} 

# Создание VPC и подсети
resource "yandex_vpc_network" "this" {
  name = local.vpc_network_name
}

resource "yandex_vpc_subnet" "private" {
  for_each = toset(var.zones)

  name           = "subnet-${each.value}"
  zone           = each.value
  v4_cidr_blocks = var.subnets[each.value]
  network_id     = yandex_vpc_network.this.id
}

resource "yandex_vpc_address" "this" {
  for_each = var.zones

  name = length(var.zones) > 1 ? "${local.linux_vm_name}-address-${substr(each.value, -1, 0)}" : "${local.linux_vm_name}-address"
  external_ipv4_address {
    zone_id = each.value
  }
}

# Создание Yandex Managed Service for YDB
resource "yandex_ydb_database_serverless" "this" {
  name = local.ydb_serverless_name
}

# Создание сервисного аккаунта 
resource "yandex_iam_service_account" "bucket" {
  name = local.bucket_sa_name
}

# Назначение роли сервисному аккаунту
resource "yandex_resourcemanager_folder_iam_member" "storage_editor" {
  folder_id = var.folder_id
  role      = "storage.editor"
  member    = "serviceAccount:${yandex_iam_service_account.bucket.id}"
}

# Создание статического ключа доступа
resource "yandex_iam_service_account_static_access_key" "this" {
  service_account_id = yandex_iam_service_account.bucket.id
  description        = "static access key for object storage"
}

resource "yandex_compute_disk" "secondary" {
  for_each = {
    for z in var.zones : z => z
    if contains(var.zones, z)
  }

  name = "${var.secondary_disks.name}-${substr(each.key, -1, 0)}-0"
  zone = each.key

  type = var.secondary_disks.type
  size = var.secondary_disks.size
}


# Создание бакета 
resource "yandex_storage_bucket" "this" {
  bucket     = local.bucket_name
  access_key = yandex_iam_service_account_static_access_key.this.access_key
  secret_key = yandex_iam_service_account_static_access_key.this.secret_key
  
  depends_on = [ yandex_resourcemanager_folder_iam_member.storage_editor ]
}

resource "random_string" "bucket_name" {
  length  = 8
  special = false
  upper   = false
}

