provider "google" {
  credentials = file("~/Downloads/ingka-native-ikealabs-dev-cec4597d9e4d.json")  # Replace with the actual path to your key file
  project     = "ingka-native-ikealabs-dev"
  region      = "us-central1"   
}

resource "google_cloudfunctions_function" "ants-prices" {
  name         = "ants-prices"
  description  = "Lowering prices trigger"
  runtime      = "python310"
  source_archive_bucket = "my-bucket-name"
  source_archive_object = "my-function-archive.zip"
  trigger_http = true
  entry_point  = "hello_world"  # Your Python function name
  available_memory_mb = 256
  timeout = "60s"
}

locals {
  function_url = google_cloudfunctions_function.antsUpdatePrices.https_trigger_url
}
