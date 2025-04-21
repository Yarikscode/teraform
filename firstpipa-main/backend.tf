terraform {
  backend "s3" {
    region         = "ru-central1"
    bucket         = "genabasket-rxbvhpos"
    key            = "terraform.tfstate"

    dynamodb_table = "state-lock-table"

    endpoints = {
      s3       = "https://storage.yandexcloud.net",
      dynamodb = "https://docapi.serverless.yandexcloud.net/ru-central1/b1ge8l20fndn2spp0kk6/etn8o9gc5bqtdlkjf4tp"
    }

    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
}