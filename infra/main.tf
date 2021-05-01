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

resource "aws_ecr_repository" "repository" {
  name                 = "container-repo"
  image_tag_mutability = "MUTABLE"
}

output "kops_state_bucket_name" {
  value = aws_s3_bucket.kops_state.bucket
}


output "repository-url" {
  value = aws_ecr_repository.repository.repository_url
}
