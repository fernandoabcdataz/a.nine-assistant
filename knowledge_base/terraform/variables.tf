variable "project_id" {
  description = "the id of the google cloud project"
  type        = string
}

variable "region" {
  description = "the region to deploy resources to"
  type        = string
  default     = "australia-southeast1"
}

variable "bucket_name" {
  description = "the name of the cloud storage bucket"
  type        = string
  default     = "abcdataz_knowledge_base"
}

variable "dataset_id" {
  description = "the id of the bigquery dataset"
  type        = string
  default     = "knowledge_base"
}

variable "table_id" {
  description = "the id of the bigquery table"
  type        = string
  default     = "semantic_model_embeddings"
}

variable "service_account_id" {
  description = "the id of the service account"
  type        = string
  default     = "knowledge-base-uploader"
}