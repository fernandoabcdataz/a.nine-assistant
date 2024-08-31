# create a cloud function to run the script
resource "google_cloudfunctions_function" "upload_knowledge_base" {
  name        = "upload-knowledge-base"
  description = "function to upload knowledge base to BigQuery"
  runtime     = "python39"

  available_memory_mb   = 256
  source_archive_bucket = google_storage_bucket.knowledge_base.name
  source_archive_object = google_storage_bucket_object.function_zip.name
  entry_point           = "upload_knowledge_base"

  event_trigger {
    event_type = "google.storage.object.finalize"
    resource   = google_storage_bucket.knowledge_base.name
  }

  environment_variables = {
    GOOGLE_CLOUD_PROJECT = var.project_id
  }

  service_account_email = google_service_account.knowledge_base_uploader.email
}

# upload the cloud function code
resource "google_storage_bucket_object" "function_zip" {
  name   = "function-source.zip"
  bucket = google_storage_bucket.knowledge_base.name
  source = "../function/source.zip"
}