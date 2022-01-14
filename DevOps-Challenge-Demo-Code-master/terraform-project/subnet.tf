# resource "google_compute_subnetwork" "project-private-subnet" {
#   name          = "project-subnetwork"
#   ip_cidr_range = "10.2.0.0/24"
#   region        = "us-central1"
#   network       = vpc_network.id

# }