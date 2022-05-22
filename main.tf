locals {
  version     = "v1.2.0"
  environment = "default"
  aws_region  = "ap-northeast-1"
}

provider "aws" {
  region = "ap-northeast-1"
}

variable "github_app_key_base64" {}
variable "github_app_id" {}

resource "random_id" "random" {
  byte_length = 20
}

data "aws_caller_identity" "current" {}

module "runners" {
  source  = "philips-labs/github-runner/aws"
  version = "1.2.0"

  create_service_linked_role_spot = true
  aws_region                      = local.aws_region
  vpc_id                          = module.vpc.vpc_id
  subnet_ids                      = module.vpc.private_subnets

  prefix = local.environment
  tags = {
    Project = "ProjectX"
  }

  github_app = {
    key_base64     = var.github_app_key_base64
    id             = var.github_app_id
    webhook_secret = random_id.random.hex
  }

  webhook_lambda_zip                = "webhook.zip"
  runner_binaries_syncer_lambda_zip = "runner-binaries-syncer.zip"
  runners_lambda_zip                = "runners.zip"


  enable_organization_runners = false
  runner_extra_labels         = "default,example"

  # enable access to the runners via SSM
  enable_ssm_on_runners = true

  instance_types = ["t3.small"]

  # override delay of events in seconds
  delay_webhook_event   = 5
  runners_maximum_count = 1

  # set up a fifo queue to remain order
  fifo_build_queue = true

  # override scaling down
  scale_down_schedule_expression = "cron(* * * * ? *)"
}