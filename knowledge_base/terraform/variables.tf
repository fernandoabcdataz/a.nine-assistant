variable "project_id" {
  description = "the ID of the Google Cloud project"
  type        = string
}

variable "region" {
  description = "the region to deploy resources to"
  type        = string
  default     = "australia-southeast1"
}

variable "bucket_name" {
  description = "the name of the Cloud Storage bucket for knowledge base files"
  type        = string
  default     = "abcdataz_knowledge_base"
}

variable "dataset_id" {
  description = "the ID of the BigQuery dataset for the knowledge base"
  type        = string
  default     = "knowledge_base"
}

variable "table_id" {
  description = "the ID of the BigQuery table for semantic model embeddings"
  type        = string
  default     = "semantic_model_embeddings"
}

variable "service_account_id" {
  description = "the ID of the service account for the knowledge base uploader"
  type        = string
  default     = "knowledge-base-uploader"
}