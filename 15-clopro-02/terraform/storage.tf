resource "yandex_storage_bucket" "test" {
  access_key = var.ACCESS_KEY
  secret_key = var.SECRET_KEY
  bucket     = "netology-tf-test"
  acl        = "public-read"
}

resource "yandex_storage_object" "index-html" {
  access_key = var.ACCESS_KEY
  secret_key = var.SECRET_KEY
  bucket     = yandex_storage_bucket.test.id
  key        = "terraform.gif"
  source     = "terraform.gif"
}
