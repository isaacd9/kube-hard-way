resource "google_compute_network" "kubernetes-the-hard-way" {
  name = "kubernetes-the-hard-way"
  auto_create_subnetworks = false
  project = "${google_project.project.project_id}"
}

resource "google_compute_subnetwork" "kubernetes" {
  name = "kubernetes"
  ip_cidr_range = "10.240.0.0/24"
  network ="${google_compute_network.kubernetes-the-hard-way.self_link}"
  project = "${google_project.project.project_id}"
}

resource "google_compute_firewall" "kubernetes-the-hard-way-allow-internal" {
  name = "kubernetes-the-hard-way-allow-internal"
  network = "${google_compute_network.kubernetes-the-hard-way.self_link}"
  source_ranges = ["10.240.0.0/24", "10.200.0.0/16"]

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

  allow {
    protocol = "icmp"
  }

  project = "${google_project.project.project_id}"
  depends_on = ["google_compute_network.kubernetes-the-hard-way"]
}

resource "google_compute_firewall" "kubernetes-the-hard-way-allow-external" {
  name = "kubernetes-the-hard-way-allow-external"
  network = "${google_compute_network.kubernetes-the-hard-way.self_link}"
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports = ["22", "6443"]
  }

  allow {
    protocol = "icmp"
  }

  project = "${google_project.project.project_id}"
  depends_on = ["google_compute_network.kubernetes-the-hard-way"]
}

resource "google_compute_address" "kubernetes-the-hard-way" {
  name = "kubernetes-the-hard-way"
  project = "${google_project.project.project_id}"
}

data "google_compute_image" "ubuntu-server-16-04" {
  family = "ubuntu-1604-lts"
  project = "ubuntu-os-cloud"
}

resource "google_compute_instance" "controller" {
  count = 3
  name = "controller-${count.index}"
  machine_type = "n1-standard-1"
  tags = ["kubernetes-the-hard-way", "controller"]
  can_ip_forward = true

  boot_disk {
  initialize_params {
      size = 200
      image = "${data.google_compute_image.ubuntu-server-16-04.self_link}"
    }
  }

  network_interface {
    address = "10.240.0.1${count.index}"
    subnetwork = "${google_compute_subnetwork.kubernetes.self_link}"
  }

  service_account {
    scopes = [
      "compute-rw",
      "storage-ro",
      "service-management",
      "service-control",
      "logging-write",
      "monitoring"
    ]
  }

  depends_on = ["google_compute_subnetwork.kubernetes"]
  project = "${google_project.project.project_id}"
}

resource "google_compute_instance" "worker" {
  count = 3
  name = "worker-${count.index}"
  machine_type = "n1-standard-1"
  tags = ["kubernetes-the-hard-way", "worker"]
  can_ip_forward = true

  boot_disk {
  initialize_params {
      size = 200
      image = "${data.google_compute_image.ubuntu-server-16-04.self_link}"
    }
  }

  network_interface {
    address = "10.240.0.2${count.index}"
    subnetwork = "${google_compute_subnetwork.kubernetes.self_link}"
  }

  service_account {
    scopes = [
      "compute-rw",
      "storage-ro",
      "service-management",
      "service-control",
      "logging-write",
      "monitoring"
    ]
  }

  metadata {
    pod_cidr = "10.200.${count.index}.0/24"
  }

  depends_on = ["google_compute_subnetwork.kubernetes"]
  project = "${google_project.project.project_id}"
}
