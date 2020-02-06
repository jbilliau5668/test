# ---------------------------------------------------------------------------------------------------------------------
# Required variables for AWS
# ---------------------------------------------------------------------------------------------------------------------

variable "aws_region" {
  description = "The AWS region in which all resources will be created."
}

# ---------------------------------------------------------------------------------------------------------------------
# Standard Module Required Variables
# ---------------------------------------------------------------------------------------------------------------------

variable "app_id" {
  description = "Core ID of the application."
}

variable "application_name" {
  description = "The name of the application, whether it be a service, website, api, etc."
}

variable "environment" {
  description = "The environment name in which the infrastructure is located. (e.g. dev, test, beta, prod)"
}


# ---------------------------------------------------------------------------------------------------------------------
# Lambda Variables
# ---------------------------------------------------------------------------------------------------------------------

variable "oidc_string" {
  description = "The OIDC provider string that will be used to allow the eks pod to assume a local iam role."
}

variable "namespace" {
  description = "The namespace in EKS where the application is deployed. If not set, the assumed name will be the application name."
  default     = ""
}

variable "stream_account_id" {
  description = "The AWS account ID where the EKS cluster is located."
}