# terraform.tfvars
project              = "voting-app-430912"
region               = "us-central1"
instance_name_master = "voting-app-server-master"
instance_name_worker = "voting-app-server-worker"
machine_type         = "e2-medium"
zone                 = "us-central1-a"
image                = "projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20240723"
credentials          = "/home/khanmohamadgouse/example-voting-app/infrastructure/voting-app-430912-adc021534f2e.json"
