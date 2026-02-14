resource "google_secret_manager_secret" "secret" {
  secret_id = var.id
  project   = var.project_id

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "version" {
  secret      = google_secret_manager_secret.secret.id
  secret_data = var.secret_data

  lifecycle {
    ignore_changes = [secret_data]
  }
}

resource "google_secret_manager_secret_iam_member" "accessors" {
  count     = length(var.accessors)
  secret_id = google_secret_manager_secret.secret.id
  role      = "roles/secretmanager.secretAccessor"
  member    = var.accessors[count.index]
}
