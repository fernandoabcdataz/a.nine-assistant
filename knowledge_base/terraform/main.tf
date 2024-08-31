provider "google" {
  project = var.project_id
  region  = var.region
}

# Create Cloud Storage bucket
resource "google_storage_bucket" "knowledge_base" {
  name     = "abcdataz_knowledge_base"
  location = var.region
}

# Upload all YAML files from a directory to cloud storage
resource "google_storage_bucket_object" "knowledge_base_files" {
  for_each = fileset("${path.module}/../../knowledge_base_files", "*.yaml")
  
  name   = each.value
  bucket = google_storage_bucket.knowledge_base.name
  source = "${path.module}/../../knowledge_base_files/${each.value}"
}

# Create BigQuery dataset
resource "google_bigquery_dataset" "shared_knowledge" {
  dataset_id  = "shared_knowledge"
  description = "Dataset for shared knowledge base"
  location    = var.region
}

# Create a single BigQuery table for all embeddings
resource "google_bigquery_table" "knowledge_base_embeddings" {
  dataset_id = google_bigquery_dataset.shared_knowledge.dataset_id
  table_id   = "knowledge_base_embeddings"

  schema = <<EOF
[
  {
    "name": "entity",
    "type": "STRING",
    "mode": "REQUIRED"
  },
  {
    "name": "chunk_id",
    "type": "STRING",
    "mode": "REQUIRED"
  },
  {
    "name": "text_chunk",
    "type": "STRING",
    "mode": "REQUIRED"
  },
  {
    "name": "embedding",
    "type": "FLOAT",
    "mode": "REPEATED"
  }
]
EOF
}

# Create a service account for the script to use
resource "google_service_account" "knowledge_base_uploader" {
  account_id   = "knowledge-base-uploader"
  display_name = "Knowledge Base Uploader"
}

# Grant necessary permissions to the service account
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