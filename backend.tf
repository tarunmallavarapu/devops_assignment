terraform {
  backend "s3" {
    bucket   = "test10052023"
    profile  = "test"
    key      = "test/terraform.tfstate"
    region   = "ap-northeast-2"
  }
}