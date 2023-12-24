variable "zone" {
  default = "ru-central1-a"
}

variable "FOLDER_ID" {
    type        = string
    description = "ENV Variable FOLDER_ID"
}

variable "NETOLOGY_DBPASS" {
    type        = string
    description = "ENV password for netology_db"
    sensitive = true
}
