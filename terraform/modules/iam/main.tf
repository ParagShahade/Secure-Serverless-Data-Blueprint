resource "google_service_account" "service_account" {
  account_id   = var.name
  display_name = var.display_name
  project      = var.project_id
}

resource "google_project_iam_member" "roles" {
  for_each = toset(var.roles)

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.service_account.email}"
}
