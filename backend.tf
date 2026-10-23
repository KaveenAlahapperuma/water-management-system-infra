terraform {
  backend "s3" {
    bucket       = "wms-tfstate"
    key          = "wms/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}