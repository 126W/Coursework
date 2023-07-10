variable yc_token {}
variable yc_cloud_id {}
variable yc_folder_id {}
variable yc_public_key {}
variable yc_private_key {}





#=================
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 1.5.2"
}
#==провайдер
provider "yandex" {
  token        = var.yc_token
  cloud_id     = var.yc_cloud_id
  folder_id    = var.yc_folder_id
}

#==сети
resource "yandex_vpc_network" "network1" {
  name = "network1"
}
#==создание подсетей
resource "yandex_vpc_subnet" "subnet1" {
  name = "subnet1"
  zone = "ru-central1-a"
  network_id = yandex_vpc_network.network1.id
  v4_cidr_blocks = ["10.0.1.0/24"]
}
resource "yandex_vpc_subnet" "subnet2" {
  name = "subnet2"
  zone = "ru-central1-b"
  network_id = yandex_vpc_network.network1.id
  v4_cidr_blocks = ["10.0.2.0/24"]
}

#==web1 nginx1
resource "yandex_compute_instance" "web1"{
  name = "web1"
  zone = "ru-central1-a"
  resources{
    cores = 2
    core_fraction = 20
    memory = 2
  }

  boot_disk{
    initialize_params {
      image_id = "fd8n3alcbfgd491kviic"
      size = 10
      description = "boot disk for web1"
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.subnet1.id
    nat = true
  }
  metadata = {
    user-data = "${file("./metadata.txt")}"
  }
}

#==web2 nginx2
resource "yandex_compute_instance" "web2"{
  name = "web2"
  zone = "ru-central1-b"
  resources{
    cores = 2
    core_fraction = 20
    memory = 2
  }

  boot_disk{
    initialize_params {
      image_id = "fd8n3alcbfgd491kviic"
      size = 10
      description = "boot disk for web2"
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.subnet2.id
    nat = true
  }
  metadata = {
    user-data = "${file("./metadata.txt")}"
  }
}

#==prometheus
resource "yandex_compute_instance" "prometheusmonitor"{
  name = "prometheusmonitor"
  zone = "ru-central1-a"
  resources{
    cores = 2
    core_fraction = 20
    memory = 2
  }

  boot_disk{
    initialize_params {
      image_id = "fd8n3alcbfgd491kviic"
      size = 10
      description = "boot disk for prometheusmonitor"
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.subnet1.id
    nat = true
  }
  metadata = {
    user-data = "${file("./metadata.txt")}"
  }
}

#==grafana
resource "yandex_compute_instance" "grafanamonitor"{
  name = "grafanamonitor"
  zone = "ru-central1-a"
  resources{
  cores = 2
  core_fraction = 20
  memory = 2
  }

  boot_disk{
    initialize_params {
    image_id =  "fd8n3alcbfgd491kviic"
    size = 10
    description = "boot disk for grafanamonitor"
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.subnet1.id
    nat = true
  }
  metadata = {
    user-data = "${file("./metadata.txt")}"
  }
}

#==elastic
resource "yandex_compute_instance" "elastic"{
  name = "elastic"
  zone = "ru-central1-a"

  resources{
    cores = 4
    core_fraction = 20
    memory = 8
  }

  boot_disk{
    initialize_params {
      image_id = "fd8n3alcbfgd491kviic"
      size = 20
      description = "boot disk for elastic"
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.subnet1.id
    nat = true
  }
  metadata = {
    user-data = "${file("./metadata.txt")}"
  }
}

#==kibana
resource "yandex_compute_instance" "kibana"{
  name = "kibana"
  zone = "ru-central1-a"

  resources{
    cores = 2
    core_fraction = 20
    memory = 4
  }

  boot_disk{
    initialize_params {
      image_id = "fd8n3alcbfgd491kviic"
      size = 20
      description = "boot disk for kibana"
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.subnet1.id
    nat = true
  }
  metadata = {
    user-data = "${file("./metadata.txt")}"
  }
}
