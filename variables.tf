variable "tf_deploy_id" {
  description = "Deploy ID tag"
  type        = string
}
variable "tf_ec2_ami_l" {
  description = "AMI"
  type        = string
}
variable "tf_ec2_ami_w" {
  description = "AMI"
  type        = string
}
variable "tf_ec2_create_a2c_instance_l" {
  description = "EC2 Instance create"
  type        = bool
  default     = false
}
variable "tf_ec2_create_a2c_instance_w" {
  description = "EC2 Instance create"
  type        = bool
  default     = false
}
variable "tf_ec2_instance_type_l" {
  description = "EC2 Instance type"
  type        = string
}
variable "tf_ec2_instance_type_w" {
  description = "EC2 Instance type"
  type        = string
}
variable "tf_ec2_public_ip" {
  description = "Public IP"
  type        = string
}
variable "tf_ec2_subnet_id" {
  description = "Subnet ID"
  type        = string
}
variable "tf_ec2_vol_size_l" {
  description = "Volume size"
  type        = number
}
variable "tf_ec2_vol_size_w" {
  description = "Volume size"
  type        = number
}
variable "tf_ec2_vol_type_l" {
  description = "Volume type"
  type        = string
}
variable "tf_ec2_vol_type_w" {
  description = "Volume type"
  type        = string
}
variable "tf_provider_aws_profile" {
  description = "AWS Profile"
  type        = string
}
variable "tf_provider_region" {
  description = "Region"
  type        = string
}
variable "tf_s3_alias" {
  description = "Alias"
  type        = string
}
variable "tf_sg_ips_mgmt" {
  description = "IP Addresses for Management"
  type        = list(string)
}
variable "tf_sg_vpc_id" {
  description = "VPC ID"
  type        = string
}
variable "tf_tags" {
  description = "Tags"
  type        = map(string)
}
variable "tf_the_sufix" {
  description = "The Sufix"
  type        = string
}
