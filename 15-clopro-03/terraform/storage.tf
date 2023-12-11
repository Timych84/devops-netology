resource "yandex_storage_bucket" "test" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = "netology-tf-test.timych.ru"
  acl        = "public-read"
  website {
    index_document = "index.html"
    error_document = "error.html"
  }
  https {
    certificate_id = yandex_cm_certificate.le-certificate.id
  }
  # server_side_encryption_configuration {
  #     rule {
  #       apply_server_side_encryption_by_default {
  #         kms_master_key_id = yandex_kms_symmetric_key.key-net-a.id
  #         sse_algorithm     = "aws:kms"
  #       }
  #     }
  #   }
}

resource "yandex_storage_object" "terraform-gif" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = yandex_storage_bucket.test.id
  key        = "terraform.gif"
  source     = "terraform.gif"
  acl        = "public-read"
}

resource "yandex_storage_object" "index-html" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = yandex_storage_bucket.test.id
  key        = "index.html"
  source     = "index.html"
  acl        = "public-read"
}

resource "yandex_storage_object" "error-html" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = yandex_storage_bucket.test.id
  key        = "error.html"
  source     = "error.html"
  acl        = "public-read"
}


locals {
  url = yandex_cm_certificate.le-certificate.challenges[0].http_url
  extracted_part = regex("^http[s]*:\\/\\/[^\\/]+\\/(.+)$", local.url)[0]
}



resource "yandex_storage_object" "lets" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = yandex_storage_bucket.test.id
  key        = local.extracted_part
  content    = yandex_cm_certificate.le-certificate.challenges[0].http_content
  acl        = "public-read"
}
