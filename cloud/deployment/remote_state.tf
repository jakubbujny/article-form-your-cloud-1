data "terraform_remote_state" "network_state" {
  backend = "s3"
  config {
    bucket = "jakubbujny-article-form-your-cloud-1"
    region = "eu-central-1"
    key = "network"
  }
}
