provider "google" {
  project = "my-project-iti-337311"
  region  = "us-central1"
  zone    = "us-central1-c"
}

resource "google_compute_network" "project-vpc" {
  name = "project-vpc"
  auto_create_subnetworks = false
  mtu                     = 1460
}

resource "google_compute_subnetwork" "project-private-subnet" {
  name          = "project-private-subnet"
  ip_cidr_range = "10.0.0.0/24"
  region        = "us-central1"
  network       = google_compute_network.project-vpc.id
}

resource "google_service_account" "project-service_account" {
  account_id   = "project-service_account.id"
  display_name = "Service Account"
}

resource "google_compute_instance" "project-vm" {
  name         = "project-vm"
  machine_type = "f1-micro"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }

  # service_account {
  # # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
  # email  = service-account-id
  # scopes = ["cloud-platform"]
  # }
}

data "google_iam_policy" "admin" {
  binding {
    role = "roles/iap.tunnelResourceAccessor"
    members = [
      "user:eng.dalia.badr@gmail.com",
    ]
  }
}

resource "google_iap_tunnel_instance_iam_policy" "policy" {
  project = google_compute_instance.tunnelvm.project
  zone = google_compute_instance.tunnelvm.zone
  instance = google_compute_instance.tunnelvm.name
  policy_data = data.google_iam_policy.admin.policy_data
}

    network_interface {
    network = "default"

    access_config {
      // Ephemeral public IP
    }
  }
  # network_interface {
  #   # A default network is created for all GCP projects
  #   network = google_compute_network.vpc_network.self_link
  #   access_config {
  #   }
  # }
}

resource "google_container_cluster" "project-cluster" {
  name       = "project-cluster"
  location   = "us-central1"
  network    = google_compute_network.project-vpc.id
  subnetwork = google_compute_subnetwork.id
  
  private_cluster_config {
    master_ipv4_cidr_block  = "172.16.0.0/28"
    enable_private_nodes    = true
    enable_private_endpoint = true
  }

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block = "10.0.1.0/24"
    }
  }
  ip_allocation_policy {
    cluster_ipv4_cidr_block  = "/21"
    services_ipv4_cidr_block = "/21"
  }

  remove_default_node_pool = true
  initial_node_count       = 1
}

resource "google_service_account" "project-service-account" {
  account_id   = "my-project-iti-337311"
  display_name = "project-service-account"
}

resource "google_project_iam_binding" "project-binding" {
  project = "my-project-iti-337311"
  role    = "roles/container.admin"

  members = [
    "serviceAccount:${project-service_account.id}"
  ]
}

resource "google_container_node_pool" "project-node" {
  name       = "project-node"
  location   = "us-central1"
  cluster    = google_container_cluster.project-cluster
  node_count = 1

  node_config {
    preemptible  = false
    machine_type = "e2-micro"
    service_account = service-account-id
    oauth_scopes = []
  }
}