terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket-goit"
    key            = "lesson-6/terraform.tfstate" 
    region         = "eu-central-1"               
    dynamodb_table = "terraform-locks"            
    encrypt        = true                         
  }
}
