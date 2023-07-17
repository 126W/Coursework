#=====================================================
resource "yandex_compute_snapshot_schedule" "default" {

  name = "snapshot-two"

  schedule_policy {
    expression = "30 23 ? * *"
  }

  snapshot_count = 7

  disk_ids = [
     "epdf3end2ejdd51us984",
     "fhm31t0go2gvslu7db6o",
     "fhm7f1pogbbu0vre7oj4",
     "fhmeh34as05ca4fjjr3n",
     "fhmgorv70tb6u2fj1arc",
     "fhmrk11derqihms225mq"
  ]
}
