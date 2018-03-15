provider "google" {
  region = "us-west-1"
  credentials = "${file('account.json')}"
}

resource "google_project" "project" {
  name = "kube-hard-way"
  project_id = "healthy-reason-196505"
}
