data "aws_iam_policy_document" "a2c_access" {
  statement {
    sid    = "1"
    effect = "Allow"
    actions = [
      "apprunner:*",
      "cloudformation:*",
      "codebuild:CreateProject",
      "codebuild:DeleteProject",
      "codebuild:TagResource",
      "codecommit:CreateCommit",
      "codecommit:CreateRepository",
      "codecommit:GetBranch",
      "codecommit:GetRepository",
      "codecommit:TagResource",
      "codepipeline:CreatePipeline",
      "codepipeline:GetPipeline",
      "codepipeline:GetPipelineState",
      "codepipeline:TagResource",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:CreateKeyPair",
      "ec2:CreateSecurityGroup",
      "ec2:CreateTags",
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeImages",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeKeyPairs",
      "ec2:DescribeRouteTables",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeVpcs",
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:CreateRepository",
      "ecr:DescribeRepositories",
      "ecr:GetAuthorizationToken",
      "ecr:InitiateLayerUpload",
      "ecr:ListImages",
      "ecr:PutImage",
      "ecr:TagResource",
      "ecr:UploadLayerPart",
      "ecs:CreateCluster",
      "ecs:CreateService",
      "ecs:DeregisterTaskDefinition",
      "ecs:DescribeClusters",
      "ecs:DescribeServices",
      "ecs:RegisterTaskDefinition",
      "ecs:TagResource",
      "ecs:UpdateService",
      "elasticloadbalancing:*",
      "events:*",
      "iam:AddRoleToInstanceProfile",
      "iam:AttachRolePolicy",
      "iam:CreateInstanceProfile",
      "iam:CreatePolicy",
      "iam:CreateRole",
      "iam:CreateServiceLinkedRole",
      "iam:DeleteRolePolicy",
      "iam:GetRole",
      "iam:GetRolePolicy",
      "iam:PassRole",
      "iam:PutRolePolicy",
      "iam:TagInstanceProfile",
      "iam:TagRole",
      "iam:UntagInstanceProfile",
      "iam:UntagRole",
      "kms:Decrypt",
      "lambda:CreateFunction",
      "lambda:GetFunction",
      "lambda:GetFunctionCodeSigningConfig",
      "lambda:InvokeFunction",
      "lambda:TagResource",
      "lambda:UntagResource",
      "logs:CreateLogGroup",
      "logs:PutRetentionPolicy",
      "logs:TagResource",
      "servicediscovery:*",
      "ssm:CreateDocument",
      "ssm:GetParameter",
      "ssm:ListTagsForResource"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    sid     = "2"
    effect  = "Allow"
    actions = ["application-transformation:PutMetricData"]
    resources = [
      "*"
    ]
  }
  statement {
    sid     = "3"
    effect  = "Allow"
    actions = ["application-transformation:PutLogData"]
    resources = [
      "*"
    ]
  }
}
resource "aws_iam_policy" "a2c_policy" {
  name        = "App2ContainerAccessPolicy"
  path        = "/"
  description = "App2Container access policy"
  policy      = data.aws_iam_policy_document.a2c_access.json
}
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    sid     = "1"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}
resource "aws_iam_role" "ec2_instance_role" {
  name               = var.ec2_instance_role
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}
resource "aws_iam_role_policy_attachment" "a2c_policy_attach" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = aws_iam_policy.a2c_policy.arn
}
resource "aws_iam_role_policy_attachment" "s3_full_policy_attach" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
resource "aws_iam_role_policy_attachment" "cloudmap_full_policy_attach" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCloudMapFullAccess"
}
resource "aws_iam_role_policy_attachment" "secret_manager_policy_attach" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}
resource "aws_iam_role_policy_attachment" "ec2_role_policy_attach" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}
resource "aws_iam_instance_profile" "this" {
  name = var.iam_instance_profile
  role = aws_iam_role.ec2_instance_role.name
  path = "/"
}
