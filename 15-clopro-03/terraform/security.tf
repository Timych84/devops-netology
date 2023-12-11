resource "yandex_kms_symmetric_key" "key-net-a" {
  name              = "netology-symetric-key"
  description       = "symmetric key for netology"
  default_algorithm = "AES_256"
  rotation_period   = "8760h"
  folder_id = var.FOLDER_ID
}


resource "yandex_iam_service_account" "sa" {
  name = "netology-15-03"
  folder_id = var.FOLDER_ID
}

resource "yandex_resourcemanager_folder_iam_member" "sa-editor" {
  folder_id = var.FOLDER_ID
  role      = "storage.editor"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "kms" {
  folder_id = var.FOLDER_ID
  role      = "kms.keys.encrypterDecrypter"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
}

resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.sa.id
  description        = "static access key for object storage"
}

resource "yandex_cm_certificate" "le-certificate" {
  name    = "netology"
  domains = ["netology-tf-test.timych.ru"]

  managed {
  challenge_type = "HTTP"
  }
}
