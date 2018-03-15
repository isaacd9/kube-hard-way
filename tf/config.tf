provider "google" {
  region = "us-west1"
  zone = "us-west1-c"
  credentials = "${file("../secrets/account.json")}"
  project = "${file("../secrets/project_id")}"
}

data "google_project" "project" {}
