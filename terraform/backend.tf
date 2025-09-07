terraform {
  backend "s3" {
    bucket         = "s3-bucket-for-bits-dissertation" # Change this
    key            = "BerryBytes/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "state-lock-table" # Change this
    encrypt        = true
  }
}