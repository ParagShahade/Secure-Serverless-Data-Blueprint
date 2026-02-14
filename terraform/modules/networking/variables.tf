variable "project_id" {
  description = "The ID of the project."
  type        = string
}

variable "region" {
  description = "The region for resources."
  type        = string
}

variable "network_name" {
  description = "The name of the VPC network."
  type        = string
}

variable "subnet_name" {
  description = "The name of the subnet."
  type        = string
}

variable "subnet_ip_cidr_range" {
  description = "The IP CIDR range for the subnet."
  type        = string
}

variable "connector_name" {
  description = "The name of the VPC Access Connector."
  type        = string
}

variable "connector_machine_type" {
  description = "Machine type for the connector."
  type        = string
}

variable "connector_min_instances" {
  description = "Min instances for the connector."
  type        = number
}

variable "connector_max_instances" {
  description = "Max instances for the connector."
  type        = number
}

variable "labels" {
  description = "A mapping of labels to assign to the network resources."
  type        = map(string)
  default     = {}
}
