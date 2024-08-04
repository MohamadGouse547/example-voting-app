# variables.tf
variable "project" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "us-central1"
}

variable "instance_name_master" {
  description = "The name of the compute instance"
  type        = string
  default     = "voting-app-server-master"
}

variable "instance_name_worker" {
  description = "The name of the compute instance"
  type        = string
  default     = "voting-app-server-worker"
}

variable "machine_type" {
  description = "The machine type for the instance"
  type        = string
  default     = "f1-micro"
}

variable "zone" {
  description = "The zone for the instance"
  type        = string
  default     = "us-central1-a"
}

variable "image" {
  description = "The image of the instance"
  type        = string
  default     = "projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20240723"
}

variable "credentials" {
  description = "The path to the key"
  type        = string
  default     = "/home/khanmohamadgouse/example-voting-app/infrastructure/voting-app-430912-adc021534f2e.json"
}
