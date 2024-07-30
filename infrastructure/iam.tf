resource "google_service_account" "app_service_account" {
  account_id   = "app-service-account"
  display_name = "App Service Account"
}

resource "google_project_iam_member" "app_sql_role" {
  project = var.project
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.app_service_account.email}"
}