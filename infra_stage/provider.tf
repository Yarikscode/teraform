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

provider "yandex" {
  alias                    = "test"
  zone                     = "ru-central1-a"
  folder_id                = "b1g231g8al8021o48n9o"
  service_account_key_file = "/home/yaroslav/key.json"
} 

provider "random" {
}

provider "random" {
  alias                     = "govno"
} 
