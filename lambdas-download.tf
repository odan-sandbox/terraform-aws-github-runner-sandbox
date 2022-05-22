module "download_lambda" {
  source  = "philips-labs/github-runner/aws//modules/download-lambda"
  version = "1.2.0"

  lambdas = [
    {
      name = "webhook"
      tag  = local.version
    },
    {
      name = "runners"
      tag  = local.version
    },
    {
      name = "runner-binaries-syncer"
      tag  = local.version
    }
  ]
}