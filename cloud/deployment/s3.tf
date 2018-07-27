resource "aws_s3_bucket" "photos" {
    bucket = "jakubbujny-article-form-your-cloud-1-photos"
    acl    = "private"
    region = "eu-central-1"
}

resource "aws_s3_bucket" "certbot" {
    bucket = "jakubbujny-article-form-your-cloud-1-certbot"
    acl    = "private"
    region = "eu-central-1"
}