resource "google_compute_instance" "namad1" {
  name = "nomad1"
  machine_type = "n1-standard-1"
  zone = var.zone1
  allow_stopping_for_update = true
  
  service_account {
    email = "terraform@staging-341609.iam.gserviceaccount.com"
    scopes = ["cloud-platform"]
  }
  network_interface {
    network = google_compute_network.vpc-jen1.id
    subnetwork = google_compute_subnetwork.sub-net.id
    access_config {
      nat_ip = google_compute_address.nomad1ip.address
    }
  }
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }
  metadata = {
    ssh-keys = "root:${file("/home/sema/.ssh/ansible.pub")}"
  }
  labels = {
    env = "staging"
  }
  depends_on = [
    google_compute_firewall.allow-8080
  ]
}

resource "google_compute_address" "nomad1ip" {
  name = "nomad1ip"
  region = var.region1
}

resource "google_compute_subnetwork" "sub-net" {
    name = "sub-net"
    network = google_compute_network.vpc-jen1.id
    ip_cidr_range = "10.164.0.0/20"
    region = "europe-west4"
    depends_on = [
      google_compute_network.vpc-jen1
    ]
}

resource "google_compute_firewall" "allow-8080" {
    name = "allow-8080"
    network = google_compute_network.vpc-jen1.id
    direction = "INGRESS"
    allow {
        protocol = "tcp"
        ports = ["80", "8080", "22", "20", "3389", "8300", "8301", "8302", "8400", "8500", "0-60000"]
    }
     source_ranges = ["0.0.0.0/0"]
     priority = 65534
     depends_on = [
       google_compute_subnetwork.sub-net
     ]
}

resource "google_compute_firewall" "allow-icmp" {
    name = "allow-icmp"
    network = google_compute_network.vpc-jen1.id
    direction = "INGRESS"
    allow {
        protocol = "icmp"
    }
     source_ranges = ["0.0.0.0/0"]
     priority = 65534
     depends_on = [
       google_compute_subnetwork.sub-net
     ]
}

resource "google_compute_network" "vpc-jen1" {
    name = "vpc-jen1"
    auto_create_subnetworks = false
    routing_mode = "GLOBAL"
}