variable "aws_region" {
  description = "Default AWS Region for this project"
  type        = string
  default     = "eu-central-1"
}

variable "raw_data_bucket_name" {
  description = "AWS S3 bucket name"
  type        = string
  default     = "xavierosee-slaythedata-raw"

  validation {
    condition     = length(var.raw_data_bucket_name) > 2 && length(var.raw_data_bucket_name) < 64 && can(regex("^[0-9A-Za-z-]+$", var.raw_data_bucket_name))
    error_message = "The bucket name must follow naming rules. Check them out at: https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucketnamingrules.html."
  }
}

variable "access_logging_bucket_name" {
  description = "S3 bucket for access logging storage"
  type        = string
  default     = "xavierosee-slaythedata-access-logging"

  validation {
    condition     = length(var.access_logging_bucket_name) > 2 && length(var.access_logging_bucket_name) < 64 && can(regex("^[0-9A-Za-z-]+$", var.access_logging_bucket_name))
    error_message = "The bucket name must follow naming rules. Check them out at: https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucketnamingrules.html."
  }
}
