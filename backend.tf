# terraform {
#   backend "s3" {
#     bucket         = "terraform-state-bucket-goit"
#     key            = "goit/terraform.tfstate" 
#     region         = "eu-central-1"               
#     # dynamodb_table = "terraform-locks"  
#     use_lockfile   = true      
#     encrypt        = true                         
#   }
# }
