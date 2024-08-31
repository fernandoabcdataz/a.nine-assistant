provider "google" {
  project = var.project_id
  region  = var.region
}

# create cloud storage bucket
resource "google_storage_bucket" "knowledge_base" {
  name     = var.bucket_name
  location = var.region
  uniform_bucket_level_access = true
}

# upload all yaml files from a directory to cloud storage
resource "google_storage_bucket_object" "knowledge_base_files" {
  for_each = fileset("${path.module}/../../knowledge_base_files", "*.yaml")
  
  name   = each.value
  bucket = google_storage_bucket.knowledge_base.name
  source = "${path.module}/../../knowledge_base_files/${each.value}"
}

# create bigquery dataset
resource "google_bigquery_dataset" "shared_knowledge" {
  dataset_id                 = var.dataset_id
  friendly_name              = "shared Knowledge Base"
  description                = "dataset for shared knowledge base"
  location                   = var.region
  delete_contents_on_destroy = true
}

# create a single BigQuery table for all embeddings
resource "google_bigquery_table" "knowledge_base_embeddings" {
  dataset_id          = google_bigquery_dataset.shared_knowledge.dataset_id
  table_id            = var.table_id
  deletion_protection = false

  schema = <<EOF
[
  {
    "name": "entity",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "the name of the entity or semantic model"
  },
  {
    "name": "chunk_id",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "unique identifier for the text chunk"
  },
  {
    "name": "text_chunk",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "the text content of the chunk"
  },
  {
    "name": "embedding",
    "type": "FLOAT",
    "mode": "REPEATED",
    "description": "the vector embedding of the text chunk"
  }
]
EOF
}

# create a service account for the script to use
resource "google_service_account" "knowledge_base_uploader" {
  account_id   = var.service_account_id
  display_name = "knowledge base uploader"
  description  = "service account for uploading knowledge base data to BigQuery"
}

# grant necessary permissions to the service account
resource "google_project_iam_member" "storage_object_viewer" {
  project = var.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.knowledge_base_uploader.email}"
}

resource "google_project_iam_member" "bigquery_data_editor" {
  project = var.project_id
  role    = "roles/bigquery.dataEditor"
  member  = "serviceAccount:${google_service_account.knowledge_base_uploader.email}"
}

resource "google_project_iam_member" "bigquery_job_user" {
  project = var.project_id
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${google_service_account.knowledge_base_uploader.email}"
}

# create a cloud function to run the script
resource "google_cloudfunctions_function" "upload_knowledge_base" {
  name        = "upload-knowledge-base"
  description = "function to upload knowledge base to BigQuery"
  runtime     = "python39"

  available_memory_mb   = 256
  source_archive_bucket = google_storage_bucket.knowledge_base.name
  source_archive_object = google_storage_bucket_object.function_zip.name
  entry_point           = "upload_knowledge_base"
  timeout               = 540
  max_instances         = 10

  event_trigger {
    event_type = "google.storage.object.finalize"
    resource   = google_storage_bucket.knowledge_base.name
  }

  environment_variables = {
    GOOGLE_CLOUD_PROJECT = var.project_id
    BIGQUERY_DATASET     = var.dataset_id
    BIGQUERY_TABLE       = var.table_id
  }

  service_account_email = google_service_account.knowledge_base_uploader.email
}

# prepare and upload the cloud function code
data "archive_file" "function_zip" {
  type        = "zip"
  source_dir  = "../function"
  output_path = "../function/source.zip"
}

resource "google_storage_bucket_object" "function_zip" {
  name   = "function-source-${data.archive_file.function_zip.output_md5}.zip"
  bucket = google_storage_bucket.knowledge_base.name
  source = data.archive_file.function_zip.output_path
}