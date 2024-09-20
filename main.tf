module "s3_a2c" {
  source = "github.com/terraform-aws-modules/terraform-aws-s3-bucket"
  # Input definitions
  create_bucket = true
  bucket        = "a2c-data-${var.tf_s3_alias}-${var.tf_deploy_id}-${var.tf_the_sufix}"
  tags          = merge(var.tf_tags, { "Name" : "AWS App2Container", "Deploy ID" : "${var.tf_deploy_id}-${var.tf_the_sufix}" })
}
module "iam_a2c_policies" {
  source = "./iam_policy"
  # Input definitions
  ec2_instance_role    = "EC2InstanceRole-${var.tf_deploy_id}-${var.tf_the_sufix}"
  iam_instance_profile = "InstanceProfile-${var.tf_deploy_id}-${var.tf_the_sufix}"
}
resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
module "key_pair" {
  source = "github.com/terraform-aws-modules/terraform-aws-key-pair"
  # Input definitions
  key_name   = "a2c-key-${var.tf_deploy_id}-${var.tf_the_sufix}"
  public_key = trimspace(tls_private_key.this.public_key_openssh)
}
resource "aws_secretsmanager_secret" "key_pair" {
  name = "/cnam-tools/a2c-${var.tf_deploy_id}-${var.tf_the_sufix}/key_pair"
  tags = merge(var.tf_tags, { "Name" : "AWS App2Container", "Deploy ID" : "${var.tf_deploy_id}-${var.tf_the_sufix}" })
}
resource "aws_secretsmanager_secret_version" "key_pair" {
  secret_id     = aws_secretsmanager_secret.key_pair.id
  secret_string = try(tls_private_key.this.private_key_pem)
}
module "sg_win" {
  source = "github.com/terraform-aws-modules/terraform-aws-security-group/modules/rdp"
  # Input definitions
  count               = var.tf_ec2_create_a2c_instance_w ? 1 : 0
  name                = "a2cw-sg-${var.tf_deploy_id}-${var.tf_the_sufix}"
  description         = "Allow access from management subnets"
  vpc_id              = var.tf_sg_vpc_id
  ingress_cidr_blocks = var.tf_sg_ips_mgmt
  egress_rules        = ["all-all"]
}
module "a2c_instance_w" {
  source = "github.com/terraform-aws-modules/terraform-aws-ec2-instance"
  # Input definitions
  count         = var.tf_ec2_create_a2c_instance_w ? 1 : 0
  depends_on    = [module.iam_a2c_policies, module.sg_win, module.key_pair]
  subnet_id     = var.tf_ec2_subnet_id
  ami           = var.tf_ec2_ami_w
  instance_type = var.tf_ec2_instance_type_w
  root_block_device = [
    {
      volume_type = var.tf_ec2_vol_type_w
      volume_size = var.tf_ec2_vol_size_w
    },
  ]
  associate_public_ip_address = var.tf_ec2_public_ip
  vpc_security_group_ids      = [var.tf_ec2_create_a2c_instance_w ? module.sg_win[0].security_group_id : ""]
  key_name                    = module.key_pair.key_pair_name
  user_data                   = "./user_data/user_data.ps1"
  tags                        = merge(var.tf_tags, { "Name" : "AWS App2Container Windows", "Deploy ID" : "${var.tf_deploy_id}-${var.tf_the_sufix}" })
  iam_instance_profile        = "InstanceProfile-${var.tf_deploy_id}-${var.tf_the_sufix}"
}
module "sg_lnx" {
  source = "github.com/terraform-aws-modules/terraform-aws-security-group/modules/ssh"
  # Input definitions
  count               = var.tf_ec2_create_a2c_instance_l ? 1 : 0
  name                = "a2cl-sg-${var.tf_deploy_id}-${var.tf_the_sufix}"
  description         = "Allow access from management subnets"
  vpc_id              = var.tf_sg_vpc_id
  ingress_cidr_blocks = var.tf_sg_ips_mgmt
  egress_rules        = ["all-all"]
}
module "a2c_instance_l" {
  source = "github.com/terraform-aws-modules/terraform-aws-ec2-instance"
  # Input definitions
  count         = var.tf_ec2_create_a2c_instance_l ? 1 : 0
  depends_on    = [module.iam_a2c_policies, module.sg_lnx, module.key_pair]
  subnet_id     = var.tf_ec2_subnet_id
  ami           = var.tf_ec2_ami_l
  instance_type = var.tf_ec2_instance_type_l
  root_block_device = [
    {
      volume_type = var.tf_ec2_vol_type_l
      volume_size = var.tf_ec2_vol_size_l
    },
  ]
  associate_public_ip_address = var.tf_ec2_public_ip
  vpc_security_group_ids      = [var.tf_ec2_create_a2c_instance_l ? module.sg_lnx[0].security_group_id : ""]
  key_name                    = module.key_pair.key_pair_name
  user_data                   = "./user_data/user_data.sh"
  tags                        = merge(var.tf_tags, { "Name" : "AWS App2Container Linux", "Deploy ID" : "${var.tf_deploy_id}-${var.tf_the_sufix}" })
  iam_instance_profile        = "InstanceProfile-${var.tf_deploy_id}-${var.tf_the_sufix}"
}
