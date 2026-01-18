terraform {
  backend "s3" {
    bucket = "loggingapp-terra"
    key    = "terraform.tfstate"
    region =  "us-east-1"
  }
}