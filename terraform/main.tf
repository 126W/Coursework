#=====================================================

variable yc_token {}
variable yc_cloud_id {}
variable yc_folder_id {}
variable yc_public_key {}
variable yc_private_key {}

#=====================================================

terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 1.5.2"
}

#=====================================================

#==== провайдер ====

provider "yandex" {
  token        = var.yc_token
  cloud_id     = var.yc_cloud_id
  folder_id    = var.yc_folder_id
  zone         = "ru-central1-a"
}

#=====================================================
#=====================================================
#=====================================================
#=====================================================

#==== security bastion host ====

resource "yandex_vpc_security_group" "group-bastion-host" {
  name        = "group bastion host"
  network_id  = yandex_vpc_network.network-1.id
  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

#=====================================================

#==== security group to ssh traffic ====
resource "yandex_vpc_security_group" "group-ssh-traffic" {
  name        = "security group ssh traffic"
  network_id  = yandex_vpc_network.network-1.id
  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["192.168.1.0/24", "192.168.2.0/24", "192.168.3.0/24"]
  }

  ingress {
    protocol       = "ICMP"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["192.168.1.0/24", "192.168.2.0/24", "192.168.3.0/24"]
  }
}

#=====================================================

#==== security group webservers ====
resource "yandex_vpc_security_group" "group-webservers" {
  name        = "security group webservers"
  network_id  = yandex_vpc_network.network-1.id

  ingress {
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["192.168.1.0/24", "192.168.2.0/24", "192.168.3.0/24"]
  }

  ingress {
    protocol       = "TCP"
    port           = 4040
    v4_cidr_blocks = ["192.168.1.0/24", "192.168.2.0/24", "192.168.3.0/24"]
  }

  ingress {
    protocol       = "TCP"
    port           = 9100
    v4_cidr_blocks = ["192.168.1.0/24", "192.168.2.0/24", "192.168.3.0/24"]
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}

#=====================================================

#==== security group prometheus ====
resource "yandex_vpc_security_group" "group-prometheus" {
  name        = "security group prometheus"
  network_id  = yandex_vpc_network.network-1.id

  ingress {
    protocol       = "TCP"
    port           = 9090
    v4_cidr_blocks = ["192.168.1.0/24", "192.168.2.0/24", "192.168.3.0/24"]
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}

#=====================================================

#==== security group public network grafana ====
resource "yandex_vpc_security_group" "group-public-network-grafana" {
  name        = "security group public network grafana"
  network_id  = yandex_vpc_network.network-1.id

  ingress {
    protocol       = "TCP"
    port           = 3000
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "TCP"
    port           = 9090
    v4_cidr_blocks = ["192.168.3.3/32"]
  }
}

#=====================================================

#==== security group elastic ====
resource "yandex_vpc_security_group" "group-elastic" {
  name        = "security group elastic"
  network_id  = yandex_vpc_network.network-1.id

  ingress {
    protocol       = "TCP"
    port           = 9200
    v4_cidr_blocks = ["192.168.1.0/24", "192.168.2.0/24", "192.168.3.0/24"]
  }

  egress {
    protocol       = "TCP"
    port           = 5601
    v4_cidr_blocks = ["192.168.1.0/24", "192.168.2.0/24", "192.168.3.0/24"]
  }
}

#=====================================================

#==== security group public network kibana ====
resource "yandex_vpc_security_group" "group-public-network-kibana" {
  name        = "security group public network kibana"
  network_id  = yandex_vpc_network.network-1.id

  ingress {
    protocol       = "TCP"
    port           = 5601
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "TCP"
    port           = 9200
    v4_cidr_blocks = ["192.168.3.22/32"]
  }
}

#=====================================================

#==== security group public load balancer ====
resource "yandex_vpc_security_group" "group-public-network-alb" {
  name        = "security group public network load balancer"
  network_id  = yandex_vpc_network.network-1.id

  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}

#=====================================================
#=====================================================
#=====================================================
#=====================================================

#==== сеть ====

resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.1.0/24"]
}

resource "yandex_vpc_subnet" "subnet-2" {
  name           = "subnet2"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.2.0/24"]
}

resource "yandex_vpc_subnet" "subnet-3" {
  name           = "subnet3"
  zone           = "ru-central1-c"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.3.0/24"]
}

#=====================================================
#=====================================================
#=====================================================

#==== bastion host ====

resource "yandex_compute_instance" "bastion-host" {

  name = "bastion-host"
  zone = "ru-central1-c"

  resources {
    cores = 2
    memory = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd80iibe8asp4inkhuhr"
      size = 10
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-3.id
    nat       = true
    security_group_ids = [yandex_vpc_security_group.group-bastion-host.id]
  }

  metadata = {
    user-data = "${file("./metadata.yml")}"
  }
}

#=====================================================

#==== web1 ====

resource "yandex_compute_instance" "web-server1" {

  name = "web1"
  zone = "ru-central1-a"

  resources {
    cores = 2
    memory = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd80iibe8asp4inkhuhr"
      size = 10
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = false
    security_group_ids = [yandex_vpc_security_group.group-ssh-traffic.id, yandex_vpc_security_group.group-webservers.id]
  }

  metadata = {
    user-data = "${file("./metadata.yml")}"
  }
}

#=====================================================

#==== web2 ====

resource "yandex_compute_instance" "web-server2" {

  name = "web2"
  zone = "ru-central1-b"

  resources {
    cores  = 2
    memory = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd80iibe8asp4inkhuhr"
      size = 10
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-2.id
    nat       = false
    security_group_ids = [yandex_vpc_security_group.group-ssh-traffic.id, yandex_vpc_security_group.group-webservers.id]
  }

  metadata = {
    user-data = "${file("./metadata.yml")}"
  }
}

#=====================================================

#==== prometheus ====

resource "yandex_compute_instance" "prometheus" {

  name = "prometheus"
  zone = "ru-central1-c"

  resources {
    cores  = 2
    memory = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd80iibe8asp4inkhuhr"
      size = 20
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-3.id
    nat       = false
    security_group_ids = [yandex_vpc_security_group.group-ssh-traffic.id, yandex_vpc_security_group.group-prometheus.id]
  }

  metadata = {
    user-data = "${file("./metadata.yml")}"
  }
}

#=====================================================

#==== grafana ====

resource "yandex_compute_instance" "grafana" {

  name = "grafana"
  zone = "ru-central1-c"

  resources {
    cores  = 2
    memory = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd80iibe8asp4inkhuhr"
      size = 20
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-3.id
    nat       = true
    security_group_ids = [yandex_vpc_security_group.group-public-network-grafana.id, yandex_vpc_security_group.group-ssh-traffic.id]
  }

  metadata = {
    user-data = "${file("./metadata.yml")}"
  }
}

#=====================================================

#==== elastic ====

resource "yandex_compute_instance" "elastic" {

  name = "elastic"
  zone = "ru-central1-c"

  resources {
    cores  = 4
    memory = 8
    core_fraction = 100
  }

  boot_disk {
    initialize_params {
      image_id = "fd80iibe8asp4inkhuhr"
      size = 20
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-3.id
    nat       = false
    security_group_ids = [yandex_vpc_security_group.group-elastic.id, yandex_vpc_security_group.group-ssh-traffic.id]
  }

  metadata = {
    user-data = "${file("./metadata.yml")}"
  }
}

#=====================================================

#==== kibana ====

resource "yandex_compute_instance" "kibana" {

  name = "kibana"
  zone = "ru-central1-c"

  resources {
    cores  = 2
    memory = 2
    core_fraction = 100
  }

  boot_disk {
    initialize_params {
      image_id = "fd80iibe8asp4inkhuhr"
      size = 10
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-3.id
    nat       = true
    security_group_ids = [yandex_vpc_security_group.group-public-network-kibana.id, yandex_vpc_security_group.group-ssh-traffic.id]
  }

  metadata = {
    user-data = "${file("./metadata.yml")}"
  }
}

#=====================================================

#==== target group ====

resource "yandex_alb_target_group" "target-group" {
  name      = "target-group"
  #region_id = "ru-central1"

  target {
    subnet_id = "${yandex_vpc_subnet.subnet-1.id}"
    ip_address   = "${yandex_compute_instance.web-server1.network_interface.0.ip_address}"
  }

  target {
    subnet_id = "${yandex_vpc_subnet.subnet-2.id}"
    ip_address   = "${yandex_compute_instance.web-server2.network_interface.0.ip_address}"
  }
}

#=====================================================

#==== backend group ====

resource "yandex_alb_backend_group" "backend-group" {
  name      = "backend-group"

  http_backend {
    name = "http-backend"
    weight = 1
    port = 80
    target_group_ids = ["${yandex_alb_target_group.target-group.id}"]
    healthcheck {
      timeout = "1s"
      interval = "1s"
      http_healthcheck {
        path  = "/"
      }
    }
  }
}

#=====================================================

#==== http router ====

resource "yandex_alb_http_router" "http-router" {
  name      = "http-router"
}

#=====================================================

#==== hosts ====

resource "yandex_alb_virtual_host" "virtual-host" {
  name      = "virtual-host"
  http_router_id = yandex_alb_http_router.http-router.id
  route {
    name = "route"

    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.backend-group.id
        timeout = "3s"
      }
    }
  }
}

#=====================================================

#==== networkloadbalancer ====

resource "yandex_alb_load_balancer" "network-load-balancer" {
  name        = "load-balancer"

  network_id  = yandex_vpc_network.network-1.id
  security_group_ids = [yandex_vpc_security_group.group-public-network-alb.id]

  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.subnet-1.id
    }

    location {
      zone_id   = "ru-central1-b"
      subnet_id = yandex_vpc_subnet.subnet-2.id
    }
  }

  listener {
    name = "my-listener"
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [ 80 ]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.http-router.id
      }
    }
  }
}

#=====================================================
