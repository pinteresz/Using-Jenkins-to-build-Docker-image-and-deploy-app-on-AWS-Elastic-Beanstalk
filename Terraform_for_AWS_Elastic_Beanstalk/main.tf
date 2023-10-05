provider "aws" {
  region = "eu-north-1"
}

resource "aws_elastic_beanstalk_application" "esz_app" {
  name        = "esz-app"
  description = "Esz's Node.js Elastic Beanstalk Application using Jenkins"
}

resource "aws_elastic_beanstalk_environment" "esz_app_environment" {
  name                = "esz-app-env"
  application         = aws_elastic_beanstalk_application.esz_app.name
  solution_stack_name = "64bit Amazon Linux 2023 v4.0.1 running Docker" 
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "IamInstanceProfile"
    value = aws_iam_instance_profile.this.id
  }
}

data "aws_iam_policy_document" "instance_role_permissions" {
  statement {
    sid = "BucketAccess"
    actions = [
      "s3:Get*",
      "s3:List*",
      "s3:PutObject"
    ]
    resources = [
      "arn:aws:s3:::elasticbeanstalk-*",
      "arn:aws:s3:::elasticbeanstalk-*/*"
    ]
  }
  statement {
    sid = "XRayAccess"
    actions = [
      "xray:PutTraceSegments",
      "xray:PutTelemetryRecords",
      "xray:GetSamplingRules",
      "xray:GetSamplingTargets",
      "xray:GetSamplingStatisticSummaries"
    ]
    resources = ["*"]
  }
  statement {
    sid = "CloudWatchLogsAccess"
    actions = [
      "logs:PutLogEvents",
      "logs:CreateLogStream",
      "logs:DescribeLogStreams",
      "logs:DescribeLogGroups"
    ]
    resources = [
      "arn:aws:logs:*:*:log-group:/aws/elasticbeanstalk*"
    ]
  }
  statement {
    sid = "ElasticBeanstalkHealthAccess"
    actions = [
      "elasticbeanstalk:PutInstanceStatistics"
    ]
    resources = [
      "arn:aws:elasticbeanstalk:*:*:application/*",
      "arn:aws:elasticbeanstalk:*:*:environment/*"
    ]
  }
}

resource "aws_iam_role_policy" "this" {
  name = "esz-elasticbeanstalk-instance-policy"
  policy = data.aws_iam_policy_document.instance_role_permissions.json
  role = aws_iam_role.this.id
}

data "aws_iam_policy_document" "instance_role_trust_policy" {
  statement {
    actions = [ "sts:AssumeRole" ]
    principals {
      type = "Service"
      identifiers = [ "ec2.amazonaws.com" ]
    }
  }
}

resource "aws_iam_role" "this" {
  name = "esz-elasticbeanstalk-instance-role"
  assume_role_policy = data.aws_iam_policy_document.instance_role_trust_policy.json
}

resource "aws_iam_instance_profile" "this" {
  name = "esz-elasticbeanstalk-instance-profile"
  role = aws_iam_role.this.id
}