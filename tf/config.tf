provider "google" {
  region = "us-west1"
  zone = "us-west1-c"
  credentials = "${file("../secrets/account.json")}"
}

resource "google_project" "project" {
  name = "kube-hard-way"
  project_id = "${file("../secrets/project_id")}"
  billing_account = "${file("../secrets/billing_account")}"
}
