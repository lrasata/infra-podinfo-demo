variable "project_id" {
  type = string
}

variable "region" {
  type    = string
  default = "us-east1"
}

variable "zone" {
  type    = string
  default = "us-east1-b"
}

variable "cluster_name" {
  type = string
}

variable "node_count" {
  type    = number
  default = 1
}
variable "machine_type" {
  type    = string
  default = "e2-micro" # free-tier eligible
}
