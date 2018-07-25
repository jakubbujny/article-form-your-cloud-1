variable "state_bucket_name" {

}

resource "aws_s3_bucket" "state" {
  bucket = "${var.state_bucket_name}"
  acl    = "private"

  versioning {
    enabled = true
  }

}