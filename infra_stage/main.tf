# Создание VPC и подсети
resource "yandex_vpc_network" "this" {
  provider = yandex.test
  name = "private"
}

resource "yandex_vpc_subnet" "private" {
  provider = yandex.test
  name           = "private"
  zone           = "ru-central1-a"
  v4_cidr_blocks = ["192.168.10.0/24"]
  network_id     = yandex_vpc_network.this.id
}




# Создание диска и виртуальной машины
resource "yandex_compute_disk" "boot_disk" {
  provider = yandex.test
  name     = "boot-disk"
  zone     = "ru-central1-a"
  image_id = "fd8ba9d5mfvlncknt2kd" # Ubuntu 22.04 LTS
  size     = 15
}

resource "yandex_iam_service_account" "alias_check" {
  provider = yandex.test
  name     = "alias-check"
}

resource "yandex_compute_instance" "this" {
  provider = yandex.test
  name                      = "linux-vm"
  allow_stopping_for_update = true
  platform_id               = "standard-v3"
  zone                      = "ru-central1-a"

  resources {
    cores  = "2"
    memory = "2"
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot_disk.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private.id
  }
}

