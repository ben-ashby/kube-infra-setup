provider "aws" {
  region  = "us-east-1"
}


resource "random_string" "tfstatename" {
  length = 6
  special = false
  upper = false
}

resource "aws_s3_bucket" "kops_state" {
  bucket        = "rmit-kops-state-${random_string.tfstatename.result}"
  acl           = "private"
  force_destroy = true
  
  versioning {
    enabled = true
  }

  tags = {
    Name = "kops remote state"
  }
}

output "kops_state_bucket_name" {
  value = aws_s3_bucket.kops_state.bucket
}