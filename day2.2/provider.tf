# Объявление провайдера
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 1.00"
}


provider "yandex" {
  zone                     = "ru-central1-a"
  folder_id                = "b1g231g8al8021o48n9o"
}

provider "random" {

}
