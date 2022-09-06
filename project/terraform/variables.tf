variable "region" {
  default     = "eu-west-2"
  description = "AWS region"
}


variable "cluster_name" {
  default = "test-project"
}

variable "cluster_timeouts" {
  description = "Create, update, and delete timeout configurations for the cluster"
  type        = map(string)
  default = {
    "hours" = "1hr"
  }
}
