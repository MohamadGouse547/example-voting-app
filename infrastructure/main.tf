#Provider configuration
provider "google" {
  credentials = file(var.credentials)
  project = var.project
  region  = var.region
  zone    = var.zone
}

#VPC network and subnet
resource "google_compute_network" "vpc_network" {
  name = "voting-app-vpc-network"
}

resource "google_compute_subnetwork" "subnet" {
  name          = "my-subnet"
  ip_cidr_range = "10.0.0.0/24"
  region        = var.region
  network       = google_compute_network.vpc_network.name
}


#Compute engine instance for master node'
resource "google_compute_instance" "app_server_master" {
  name         = var.instance_name_master
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = var.image
}
}

  network_interface {
    network    = google_compute_network.vpc_network.name
    subnetwork = google_compute_subnetwork.subnet.name

    access_config {
      // Ephemeral public IP
}
}
}

#Compute engine instance for worker node'
resource "google_compute_instance" "app_server_worker" {
  name         = var.instance_name_worker
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = var.image
}
}

  network_interface {
    network    = google_compute_network.vpc_network.name
    subnetwork = google_compute_subnetwork.subnet.name

    access_config {
      // Ephemeral public IP
}
}
}

#Cloud SQL instance
resource "google_sql_database_instance" "db_instance" {
  name             = "cloud-sql-instance"
  database_version = "MYSQL_5_7"
  region           = var.region

  settings {
    tier = "db-f1-micro"

    ip_configuration {
      authorized_networks {
        name  = "app-server"
        value = google_compute_instance.app_server.network_interface[0].access_config[0].nat_ip
      }
      authorized_networks {
        name  = "app-server-worker"
        value = google_compute_instance.app_server_worker1.network_interface[0].access_config[0].nat_ip
      }
      ipv4_enabled = true
}
}
}


#Firewall rules
resource "google_compute_firewall" "allow_ports" {
  name    = "allow-ports"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["5000", "5001", "31000", "31001", "22", "3000-10000", "30000-32767"]
}

  source_ranges = ["0.0.0.0/0"]
}
